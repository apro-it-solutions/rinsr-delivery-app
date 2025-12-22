enum OrderStatus {
  scheduled,
  pickedUp,
  processing,
  vendorPickedUp,
  serviceCompleted,
  vendorReturning,
  ready,
  readyToPickupFromHub,
  outForDelivery,
  delivered,
  washing,
  cancelled,
}

enum TaskType { pickupFromUser, hubToVendor, vendorToHub, deliveryToUser }
