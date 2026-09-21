require "test_helper"

class ConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @user1 = User.create!(
      name: "Concurrent User 1",
      email: "concurrent1@example.com",
      password: "password123",
      role: "user"
    )
    @user2 = User.create!(
      name: "Concurrent User 2",
      email: "concurrent2@example.com",
      password: "password123",
      role: "user"
    )
    @device = Device.create!(
      name: "Concurrency Camera",
      category: "Kamera",
      inventory_code: "CONC-001",
      active: true
    )
  end

  teardown do
    ActivityLog.where(record_id: @device.id).delete_all
    Loan.where(device_id: @device.id).delete_all
    @device.delete
    @user1.delete
    @user2.delete
  end

  test "Qualitaetsattribut Datenkonsistenz: Bei zwei gleichzeitigen Ausleihen wird genau eine bestaetigt" do
    results = []
    errors = []
    barrier = Concurrent::CyclicBarrier.new(2) rescue nil

    t1 = Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        begin
          barrier&.wait
          loan = Loan.borrow!(user: @user1, device: @device)
          results << { user: @user1, loan: loan }
        rescue Loan::LoanError => e
          errors << { user: @user1, error: e.message }
        rescue => e
          errors << { user: @user1, error: e.message }
        end
      end
    end

    t2 = Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        begin
          barrier&.wait
          loan = Loan.borrow!(user: @user2, device: @device)
          results << { user: @user2, loan: loan }
        rescue Loan::LoanError => e
          errors << { user: @user2, error: e.message }
        rescue => e
          errors << { user: @user2, error: e.message }
        end
      end
    end

    t1.join
    t2.join

    # Exakt eine Ausleihe war erfolgreich
    assert_equal 1, results.size, "Genau eine Ausleihe muss erfolgreich sein"
    assert_equal 1, errors.size, "Genau ein Benutzer muss abgewiesen werden"

    # Fehlermeldung ist die fachliche, verstaendliche Meldung
    assert_equal "Das Gerät wurde inzwischen von einem anderen Benutzer ausgeliehen.", errors.first[:error]

    # In der Datenbank darf exakt 1 aktive Ausleihe existieren
    assert_equal 1, Loan.where(device_id: @device.id, returned_at: nil).count
  end
end
