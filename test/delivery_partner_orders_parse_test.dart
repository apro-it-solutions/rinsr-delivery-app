// Verifies the GET /api/orders/delivery-partner sample payload (provided by
// backend on 2026-06-04) parses through GetOrdersModel and that order 297
// surfaces correctly for the assigned agent.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rinsr_delivery_partner/core/constants/enums.dart';
import 'package:rinsr_delivery_partner/features/home/data/models/get_orders_model/get_orders_model.dart';

const _sampleResponse = '''
{
  "success": true,
  "count": 1,
  "orders": [
    {
      "_id": "6a1eb6ecd0255c9f34a89291",
      "order_id": 297,
      "user_id": {
        "_id": "6a1da924da4719766fd1202d",
        "name": "Natasha",
        "phone": "+919910600526",
        "email": "natashakhanna1701@gmail.com",
        "device_tokens": ["tok"]
      },
      "vendor_id": {
        "_id": "6a05c4a008628dcaa00e6d79",
        "company_name": "Laundry House",
        "phone_number": "+917892692986",
        "full_address": "420, 20th Main Rd, 6th Block, Koramangala, Bengaluru, Karnataka",
        "location": "https://maps.app.goo.gl/oT9MZHvi8a5dMhRj6"
      },
      "vendor_ids": ["6a05c4a008628dcaa00e6d79"],
      "delivery_partner_ids": [],
      "delivery_updates": {
        "picked_up": [
          {
            "status": "accepted_for_pickup",
            "delivery_id": "6a01c3d945def10b421cf775",
            "timestamp": "2026-06-02T11:28:41.902Z",
            "_id": "6a1ebe69d0255c9f34a8affa"
          },
          {
            "status": "picked_up",
            "delivery_id": "6a01c3d945def10b421cf775",
            "timestamp": "2026-06-02T11:29:31.640Z",
            "_id": "6a1ebe9bd0255c9f34a8b253"
          }
        ],
        "delivered": [
          {
            "status": "accepted_for_return",
            "delivery_id": "6a01c3d945def10b421cf775",
            "timestamp": "2026-06-04T08:17:32.922Z",
            "_id": "6a21349c8bc20c1a51163789"
          }
        ],
        "current_delivery_partner_id": "6a01c3d945def10b421cf775"
      },
      "pickup_date": "2026-06-02T11:30:00.000Z",
      "pickup_time_slot": {"start": "17:00", "end": "18:00"},
      "pickup_address": {
        "label": "Kamala Sadan",
        "address_line": "60A, Block 5A, Koramangala, Bengaluru, Karnataka, 560095",
        "coordinates": "12.936249,77.615227"
      },
      "distance_km": 327.14,
      "service_id": {
        "_id": "69ba72bbf7ed3b6ff81a7100",
        "name": "Wash & Iron",
        "price": 250,
        "pricing_mode": "weight"
      },
      "services": [
        {
          "service_id": "69ba72bbf7ed3b6ff81a7100",
          "service_name": "Wash & Iron",
          "items": [
            {
              "item_name": "Wash & Iron",
              "price_per_piece": 50,
              "price_per_weight": 135,
              "quantity": 20,
              "estimated_weight": 2,
              "_id": "6a1eb6ecd0255c9f34a89293"
            }
          ],
          "subtotal": 270,
          "_id": "6a1eb6ecd0255c9f34a89292"
        }
      ],
      "addons": [
        {"addon_id": "69a683ecf4dec8ca2a4a40fe", "quantity": 20, "_id": "6a1eb6ecd0255c9f34a89294"}
      ],
      "total_weight_kg": "12",
      "total_no_of_clothes": "",
      "heavy_items": "",
      "delivery_date": "2026-06-05",
      "final_delivery_date": 2,
      "emergency": false,
      "estimate_total_price": 2112,
      "base_price": 1620,
      "addon_price": 400,
      "handling_price": 11,
      "express_charge": 0,
      "tax_amount": 81,
      "cart_fee": 0,
      "tip": 0,
      "from_cart": true,
      "selected_clothing_items": [
        {
          "item_name": "Wash & Iron",
          "price_per_piece": 50,
          "price_per_weight": 135,
          "quantity": 20,
          "estimated_weight": 2,
          "_id": "6a1eb6ecd0255c9f34a89295"
        }
      ],
      "pricing_type": "per_weight",
      "actual_weight": null,
      "final_total_price": null,
      "status": "ready_to_pickup_from_vendor",
      "user_status": "washing_completed",
      "order_type": "daily",
      "payment_status": "pending",
      "payment_method": "online",
      "vendor_status": "dispatched",
      "pickup_notification_at": "2026-06-02T11:29:00.000Z",
      "pickup_notification_sent": true,
      "dp_pickup_notification_at": "2026-06-02T10:30:00.000Z",
      "dp_pickup_notification_sent": true,
      "vendor_images": [],
      "notes": null,
      "qualityCheck": [
        {
          "key": "stain_visible",
          "question": "All visible stains removed?",
          "type": "boolean",
          "answer": true,
          "_id": "6a2112b08bc20c1a5115e5db"
        }
      ],
      "createdAt": "2026-06-02T10:56:44.594Z",
      "updatedAt": "2026-06-04T08:17:32.932Z",
      "hub_id": {
        "_id": "699ea79f8c4038870a179324",
        "name": "Koratty Hub",
        "location": "789X+CR7, Korraty, Junction, Jamuna Nagar, Koratty, Kerala 680308, India",
        "delivery_partner_ids": ["699d26dbbc1bf0476094ff63", "6a01c3d945def10b421cf775"]
      },
      "picked_up_delivery_partner": "6a01c3d945def10b421cf775",
      "order_returned_delivery_partner": "6a01c3d945def10b421cf775",
      "barcode_id": "RSR -RJ496O",
      "image": "uploads/1780399768824-334946977.jpg",
      "razorpay_order_id": "order_SxSO0P6zciYlgE",
      "__v": 4
    }
  ]
}
''';

void main() {
  test('delivery-partner orders sample payload parses', () {
    final model = GetOrdersModel.fromJson(
      jsonDecode(_sampleResponse) as Map<String, dynamic>,
    );

    expect(model.success, isTrue);
    expect(model.orders, hasLength(1));

    final order = model.orders!.first;
    expect(order.displayOrderID, 297);
    expect(order.computedStatus, OrderStatus.readyToPickupFromHub);
    expect(order.vendorStatus, 'dispatched');
    expect(order.vendorId?.companyName, 'Laundry House');
    expect(order.userId?.name, 'Natasha');
    expect(order.hubId?.name, 'Koratty Hub');
    expect(order.distanceInKms, 327.14);
    expect(order.orderReturnedDeliveryPartner, '6a01c3d945def10b421cf775');
    expect(order.paymentMethod, 'online');
    expect(order.isPayOnDelivery, isFalse);
    expect(order.isPaid, isFalse);

    // Return leg accepted by the agent -> order is active for them.
    const agentId = '6a01c3d945def10b421cf775';
    expect(order.hasAcceptedReturnLeg(agentId), isTrue);
    expect(order.isActiveForAgent(agentId), isTrue);
    expect(order.isTerminalForAgent, isFalse);
  });
}
