import XCTest
@testable import WhiteBrew

final class PurchaseManagerTests: XCTestCase {
    func testLifetimeMembershipIsActive() {
        XCTAssertTrue(MembershipState.lifetime.isMember)
    }

    func testFreeMembershipIsInactive() {
        XCTAssertFalse(MembershipState.free.isMember)
    }

    func testFutureAnnualMembershipIsActiveAsOfDate() {
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)
        let state = MembershipState.annual(expiresAt: now.addingTimeInterval(3600))

        XCTAssertTrue(state.isMember(asOf: now))
    }

    func testExpiredAnnualMembershipIsInactiveAsOfDate() {
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)
        let state = MembershipState.annual(expiresAt: now.addingTimeInterval(-3600))

        XCTAssertFalse(state.isMember(asOf: now))
    }

    func testEntitlementReducerAppliesLifetimeMembership() {
        let state = PurchaseManager.membershipState(
            for: [
                PurchaseEntitlement(
                    productID: PurchaseManager.lifetimeProductID,
                    expirationDate: nil
                )
            ],
            asOf: Date(timeIntervalSinceReferenceDate: 800_000_000)
        )

        XCTAssertEqual(state, .lifetime)
    }

    func testEntitlementReducerAppliesFutureAnnualMembership() {
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)
        let expirationDate = now.addingTimeInterval(3600)

        let state = PurchaseManager.membershipState(
            for: [
                PurchaseEntitlement(
                    productID: PurchaseManager.annualProductID,
                    expirationDate: expirationDate
                )
            ],
            asOf: now
        )

        XCTAssertEqual(state, .annual(expiresAt: expirationDate))
    }

    func testEntitlementReducerIgnoresExpiredAnnualMembership() {
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)

        let state = PurchaseManager.membershipState(
            for: [
                PurchaseEntitlement(
                    productID: PurchaseManager.annualProductID,
                    expirationDate: now.addingTimeInterval(-3600)
                )
            ],
            asOf: now
        )

        XCTAssertEqual(state, .free)
    }

    func testEntitlementReducerPrefersLifetimeOverAnnualMembership() {
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)

        let state = PurchaseManager.membershipState(
            for: [
                PurchaseEntitlement(
                    productID: PurchaseManager.annualProductID,
                    expirationDate: now.addingTimeInterval(3600)
                ),
                PurchaseEntitlement(
                    productID: PurchaseManager.lifetimeProductID,
                    expirationDate: nil
                )
            ],
            asOf: now
        )

        XCTAssertEqual(state, .lifetime)
    }
}
