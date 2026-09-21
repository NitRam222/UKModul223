require "test_helper"

class LoanTest < ActiveSupport::TestCase
  setup do
    @max = users(:user_max)
    @anna = users(:user_anna)
    @admin = users(:admin)
    @laptop = devices(:available_laptop)
    @borrowed_laptop = devices(:borrowed_laptop)
    @inactive_device = devices(:inactive_device)
  end

  # =========================================================================
  # Zentrale Fachregel:
  # "Ein Gerät darf gleichzeitig höchstens eine aktive Ausleihe besitzen.
  #  Ist ein Gerät bereits ausgeliehen, wird die zweite Ausleihe abgelehnt."
  # =========================================================================

  test "zentrale Fachregel: erfolgreiche Ausleihe eines verfuegbaren Geraets" do
    assert @laptop.available?

    loan = Loan.borrow!(user: @anna, device: @laptop, notes: "Projektarbeit")

    assert loan.persisted?
    assert_equal @anna, loan.user
    assert_equal @laptop, loan.device
    assert_nil loan.returned_at
    assert_not @laptop.reload.available?
    assert_equal "Ausgeliehen", @laptop.status_label
    assert_equal @anna, @laptop.current_borrower
  end

  test "zentrale Fachregel: zweite Ausleihe fuer bereits ausgeliehenes Geraet wird abgewiesen" do
    assert_not @borrowed_laptop.available?
    assert_equal @max, @borrowed_laptop.current_borrower

    exception = assert_raises(Loan::LoanError) do
      Loan.borrow!(user: @anna, device: @borrowed_laptop)
    end

    assert_equal "Das Gerät wurde inzwischen von einem anderen Benutzer ausgeliehen.", exception.message
  end

  test "zentrale Fachregel: Modellvalidierung verhindert zweite aktive Ausleihe" do
    new_loan = Loan.new(
      user: @anna,
      device: @borrowed_laptop,
      borrowed_at: Time.current
    )

    assert_not new_loan.valid?
    assert_includes new_loan.errors[:device], "ist bereits ausgeliehen"
  end

  test "zentrale Fachregel: Datenbank-Unique-Index verhindert gleichzeitige aktive Ausleihen auf DB-Ebene" do
    # Bypassing model validation to test database constraint directly
    assert_raises(ActiveRecord::RecordNotUnique) do
      duplicate_loan = Loan.new(
        user_id: @anna.id,
        device_id: @borrowed_laptop.id,
        borrowed_at: Time.current
      )
      duplicate_loan.save!(validate: false)
    end
  end

  test "Rueckgabe macht das Geraet wieder fuer die naechste Ausleihe verfuegbar" do
    active_loan = loans(:active_loan)
    device = active_loan.device
    assert_not device.available?

    # Rueckgabe durch den Ausleiher Max
    active_loan.return!(@max)

    assert active_loan.returned?
    assert_not_nil active_loan.returned_at
    assert device.reload.available?
    assert_nil device.current_borrower

    # Nun kann Anna das freigegebene Geraet ausleihen
    new_loan = Loan.borrow!(user: @anna, device: device)
    assert new_loan.persisted?
    assert_equal @anna, device.reload.current_borrower
  end

  test "nur der Ausleiher oder ein Administrator darf die Ausleihe zurueckgeben" do
    active_loan = loans(:active_loan) # gehoert Max

    # Anna versucht unberechtigt, das Geraet von Max zurueckzugeben
    assert_raises(Loan::LoanError) do
      active_loan.return!(@anna)
    end

    # Administrator darf jedes Geraet zuruecknehmen
    assert_nothing_raised do
      active_loan.return!(@admin)
    end
    assert active_loan.returned?
  end

  test "inaktives Geraet kann nicht ausgeliehen werden" do
    exception = assert_raises(Loan::LoanError) do
      Loan.borrow!(user: @anna, device: @inactive_device)
    end

    assert_equal "Das Gerät ist inaktiv und kann nicht ausgeliehen werden.", exception.message
  end

  test "Rueckgabedatum kann nicht vor dem Ausleihdatum liegen" do
    loan = Loan.new(
      user: @anna,
      device: @laptop,
      borrowed_at: Time.current,
      returned_at: 1.day.ago
    )

    assert_not loan.valid?
    assert_includes loan.errors[:returned_at], "kann nicht vor dem Ausleihdatum liegen"
  end

  test "Ausleihe und Rueckgabe erstellen Aktivitaetsprotokolleintraege" do
    assert_difference "ActivityLog.count", 2 do
      loan = Loan.borrow!(user: @anna, device: @laptop)
      loan.return!(@anna)
    end

    borrow_log = ActivityLog.where(action: "borrow", record_id: @laptop.id).last
    assert_not_nil borrow_log
    assert_equal @anna, borrow_log.user

    return_log = ActivityLog.where(action: "return", record_id: @laptop.id).last
    assert_not_nil return_log
    assert_equal @anna, return_log.user
  end
end
