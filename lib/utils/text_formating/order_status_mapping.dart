String mapOrderStatus(String status) {
  String mappedStatus = '';
  //pending = pendiente, partial = parcial, completed = facturado, enlistment = alistamiento, sent = enviado, delivered = entregado
  if (status == 'pending') {
    mappedStatus = 'Pendiente';
  } else if (status == 'partial') {
    mappedStatus = 'Parcial';
  } else if (status == 'completed') {
    mappedStatus = 'Facturado';
  } else if (status == 'enlistment') {
    mappedStatus = 'Alistamiento';
  } else if (status == 'sent') {
    mappedStatus = 'Enviado';
  } else if (status == 'delivered') {
    mappedStatus = 'Entregado';
  }
  return mappedStatus;
}
