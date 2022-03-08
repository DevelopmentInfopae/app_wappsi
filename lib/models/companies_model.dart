//To parse this JSON data, do
////
//    final CompanyModel = CompanyModelFromJson(jsonString);

import 'dart:convert';

import 'package:pos_wappsi/bloc/data_bloc.dart';

import 'package:pos_wappsi/providers/companies_provider.dart';

import 'package:pos_wappsi/utils/text_formating/functions.dart';

List<CompanyModel> companyModelFromJson(String str) => List<CompanyModel>.from(
    json.decode(str).map((x) => CompanyModel.fromJson(x)));

String companyModelToJson(List<CompanyModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CompanyModel {
  CompanyModel({
    this.id,
    this.idCloud,
    this.groupId,
    this.groupName,
    this.customerGroupId,
    this.customerGroupName,
    this.typePerson,
    this.name,
    this.firstName,
    this.secondName,
    this.firstLastname,
    this.secondLastname,
    this.company,
    this.commercialRegister,
    this.tipoDocumento,
    this.documentCode,
    this.vatNo,
    this.digitoVerificacion,
    this.address,
    this.location,
    this.subzone,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.phone,
    this.email,
    this.cf1,
    this.cf2,
    this.cf3,
    this.cf4,
    this.cf5,
    this.cf6,
    this.invoiceFooter,
    this.paymentTerm,
    this.logo,
    this.awardPoints,
    this.depositAmount,
    this.priceGroupId,
    this.priceGroupName,
    this.idPartner,
    this.tipoRegimen,
    this.cityCode,
    this.status,
    this.birthMonth,
    this.birthDay,
    this.customerOnlyForPos,
    this.customerSellerIdAssigned,
    this.customerSpecialDiscount,
    this.fuenteRetainer,
    this.ivaRetainer,
    this.icaRetainer,
    this.defaultReteFuenteId,
    this.defaultReteIvaId,
    this.defaultReteIcaId,
    this.defaultReteOtherId,
    this.customerPaymentType,
    this.customerCreditLimit,
    this.customerPaymentTerm,
    this.customerValidateMinBaseRetention,
    this.gender,
    this.logoSquare,
    this.taxExemptCustomer,
    this.initialAccountingBalanceTransferred,
    this.customerProfilePhoto,
    this.supplierType,
    this.note,
    this.lastUpdate,
  });

  String? id;
  String? idCloud;
  String? groupId;
  String? groupName;
  String? customerGroupId;
  String? customerGroupName;
  String? typePerson;
  String? name;
  String? firstName;
  String? secondName;
  String? firstLastname;
  String? secondLastname;
  String? company;
  String? commercialRegister;
  String? tipoDocumento;
  String? documentCode;
  String? vatNo;
  String? digitoVerificacion;
  String? address;
  String? location;
  String? subzone;
  String? city;
  String? state;
  String? postalCode;
  String? country;
  String? phone;
  String? email;
  String? cf1;
  String? cf2;
  String? cf3;
  String? cf4;
  String? cf5;
  String? cf6;
  String? invoiceFooter;
  String? paymentTerm;
  String? logo;
  String? awardPoints;
  double? depositAmount;
  String? priceGroupId;
  String? priceGroupName;
  String? idPartner;
  String? tipoRegimen;
  String? cityCode;
  String? status;
  String? birthMonth;
  String? birthDay;
  String? customerOnlyForPos;
  String? customerSellerIdAssigned;
  String? customerSpecialDiscount;
  String? fuenteRetainer;
  String? ivaRetainer;
  String? icaRetainer;
  String? defaultReteFuenteId;
  String? defaultReteIvaId;
  String? defaultReteIcaId;
  String? defaultReteOtherId;
  String? customerPaymentType;
  double? customerCreditLimit;
  String? customerPaymentTerm;
  String? customerValidateMinBaseRetention;
  String? gender;
  String? logoSquare;
  String? taxExemptCustomer;
  String? initialAccountingBalanceTransferred;
  String? customerProfilePhoto;
  String? supplierType;
  String? note;
  String? lastUpdate;

  static List<CompanyModel> fromJsonList(List<Map> list) {
    List<CompanyModel> customers = [];
    Map<String, dynamic> temp = {};
    for (var item in list) {
      for (var i = 0; i < item.keys.length; i++) {
        temp[item.keys.toList()[i]] = item.values.toList()[i];
      }
      customers.add(CompanyModel.fromJson(temp));
    }

    return customers;

    // prString(temp);
  }

  static Future<CompanyModel?> getCompanyDetails(String id) async {
    final res = await CompaniesProvider.findCompanyById(id);
    if (res != null) {
      return CompanyModel.fromJson(res);
    }
    return null;
  }

  static Future<CompanyModel?> getCompanyBiller() async {
    final res = await CompaniesProvider.findCompanyById(
        dataBloc.userData!.billerId.toString());
    if (res != null) {
      return CompanyModel.fromJson(res);
    }
    return null;
  }

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
        idCloud: json["id_cloud"].toString(),
        id: json["id"]?.toString() ?? '',
        groupId: json["group_id"].toString(),
        groupName: json["group_name"]?.toString() ?? '',
        customerGroupId: json["customer_group_id"]?.toString() ?? '',
        customerGroupName: json["customer_group_name"] ?? '',
        typePerson: json["type_person"]?.toString() ?? '',
        name: json["name"] ?? json["company"] ?? '',
        firstName: json["first_name"]?.toString() ?? '',
        secondName: json["second_name"]?.toString() ?? '',
        firstLastname: json["first_lastname"]?.toString() ?? '',
        secondLastname: json["second_lastname"]?.toString() ?? '',
        company: json["company"] ?? json["name"] ?? '',
        commercialRegister: json["commercial_register"]?.toString() ?? '',
        tipoDocumento: json["tipo_documento"]?.toString() ?? '',
        documentCode: json["document_code"]?.toString() ?? '',
        vatNo: json["vat_no"]?.toString() ?? '',
        digitoVerificacion: json["digito_verificacion"]?.toString() ?? '',
        address: json["address"]?.toString() ?? '',
        location: json["location"]?.toString() ?? '',
        subzone: json["subzone"]?.toString() ?? '',
        city: json["city"] ?? '',
        state: json["state"] ?? '',
        postalCode: json["postal_code"]?.toString() ?? '',
        country: json["country"] ?? '',
        phone: json["phone"]?.toString() ?? '',
        email: json["email"]?.toString() ?? '',
        cf1: json["cf1"]?.toString() ?? '',
        cf2: json["cf2"]?.toString() ?? '',
        cf3: json["cf3"]?.toString() ?? '',
        cf4: json["cf4"]?.toString() ?? '',
        cf5: json["cf5"]?.toString() ?? '',
        cf6: json["cf6"]?.toString() ?? '',
        invoiceFooter: json["invoice_footer"] ?? '',
        paymentTerm: json["payment_term"]?.toString() ?? '',
        logo: json["logo"] ?? 'logo.png',
        awardPoints: json["award_poStrings"]?.toString() ?? '',
        depositAmount:
            double.tryParse(json["deposit_amount"].toString()) ?? 0.0,
        priceGroupId: json["price_group_id"]?.toString() ?? '',
        priceGroupName: json["price_group_name"]?.toString() ?? '',
        idPartner: json["id_partner"] ?? '',
        tipoRegimen: json["tipo_regimen"]?.toString() ?? '',
        cityCode: json["city_code"] ?? '',
        status: json["status"]?.toString() ?? '',
        birthMonth: json["birth_month"]?.toString() ?? '',
        birthDay: json["birth_day"]?.toString() ?? '',
        customerOnlyForPos: json["customer_only_for_pos"]?.toString() ?? '',
        customerSellerIdAssigned:
            json["customer_seller_id_assigned"]?.toString() ?? '',
        customerSpecialDiscount:
            json["customer_special_discount"]?.toString() ?? '',
        fuenteRetainer: json["fuente_retainer"]?.toString() ?? '',
        ivaRetainer: json["iva_retainer"]?.toString() ?? '',
        icaRetainer: json["ica_retainer"]?.toString() ?? '',
        defaultReteFuenteId: json["default_rete_fuente_id"]?.toString() ?? '',
        defaultReteIvaId: json["default_rete_iva_id"]?.toString() ?? '',
        defaultReteIcaId: json["default_rete_ica_id"]?.toString() ?? '',
        defaultReteOtherId: json["default_rete_other_id"]?.toString() ?? '',
        customerPaymentType: json["customer_payment_type"]?.toString() ?? '',
        customerCreditLimit:
            double.tryParse(json["customercredit_limit"].toString()) ?? 0.0,
        customerPaymentTerm: json["customer_payment_term"]?.toString() ?? '',
        customerValidateMinBaseRetention:
            json["customer_validate_min_base_retention"]?.toString() ?? '',
        gender: json["gender"]?.toString() ?? '',
        logoSquare: json["logo_square"] ?? 'logo.png',
        taxExemptCustomer: json["tax_exempt_customer"]?.toString() ?? '',
        initialAccountingBalanceTransferred:
            json["initial_accounting_balance_transferred"]?.toString() ?? '',
        customerProfilePhoto: json["customer_profile_photo"]?.toString() ?? '',
        supplierType: json["supplier_type"]?.toString() ?? '',
        note: json["note"] ?? '',
        lastUpdate: json["last_update"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_cloud": idCloud,
        "group_id": groupId,
        "group_name": groupName,
        "customer_group_id": customerGroupId,
        "customer_group_name": customerGroupName,
        "type_person": typePerson,
        "name": name,
        "first_name": firstName,
        "second_name": secondName,
        "first_lastname": firstLastname,
        "second_lastname": secondLastname,
        "company": company,
        "commercial_register": commercialRegister,
        "tipo_documento": tipoDocumento,
        "document_code": documentCode,
        "vat_no": vatNo,
        "digito_verificacion": digitoVerificacion,
        "address": address,
        "location": location,
        "subzone": subzone,
        "city": city,
        "state": state,
        "postal_code": postalCode,
        "country": country,
        "phone": phone,
        "email": email,
        "cf1": cf1,
        "cf2": cf2,
        "cf3": cf3,
        "cf4": cf4,
        "cf5": cf5,
        "cf6": cf6,
        "invoice_footer": invoiceFooter,
        "payment_term": paymentTerm,
        "logo": logo,
        "award_points": awardPoints,
        "deposit_amount": depositAmount,
        "price_group_id": priceGroupId,
        "price_group_name": priceGroupName,
        "id_partner": idPartner,
        "tipo_regimen": tipoRegimen,
        "city_code": cityCode,
        "status": status,
        "birth_month": birthMonth,
        "birth_day": birthDay,
        "customer_only_for_pos": customerOnlyForPos,
        "customer_seller_id_assigned": customerSellerIdAssigned,
        "customer_special_discount": customerSpecialDiscount,
        "fuente_retainer": fuenteRetainer,
        "iva_retainer": ivaRetainer,
        "ica_retainer": icaRetainer,
        "default_rete_fuente_id": defaultReteFuenteId,
        "default_rete_iva_id": defaultReteIvaId,
        "default_rete_ica_id": defaultReteIcaId,
        "default_rete_other_id": defaultReteOtherId,
        "customer_payment_type": customerPaymentType,
        "customer_credit_limit": customerCreditLimit,
        "customer_payment_term": customerPaymentTerm,
        "customer_validate_min_base_retention":
            customerValidateMinBaseRetention,
        "gender": gender,
        "logo_square": logoSquare,
        "tax_exempt_customer": taxExemptCustomer,
        "initial_accounting_balance_transferred":
            initialAccountingBalanceTransferred,
        "customer_profile_photo": customerProfilePhoto,
        "supplier_type": supplierType,
        "note": note,
        "last_update": lastUpdate,
      };

  Map<String, dynamic> customerToJson() => {
        "group_id": groupId,
        "group_name": groupName,
        "customer_group_id": customerGroupId ?? 1,
        "customer_group_name": customerGroupName,
        "type_person": typePerson,
        "name": (firstName ?? '') +
            ' ' +
            ((secondName ?? '' ' ') +
                ((firstLastname ?? '') + ' ') +
                (secondLastname ?? '')),
        "first_name": firstName,
        "second_name": (secondName ?? '') == '' ? '  ' : secondName,
        "first_lastname": firstLastname,
        "second_lastname": (secondLastname ?? '') == '' ? ' ' : secondLastname,
        "company": company ??
            ((firstName ?? '') +
                ' ' +
                ((secondName ?? '' ' ') +
                    (firstLastname ?? '') +
                    ' ' +
                    (secondLastname ?? ''))),
        "commercial_register": commercialRegister ?? '',
        "tipo_documento": tipoDocumento ?? '',
        "document_code": documentCode ?? '',
        "vat_no": vatNo ?? '',
        "digito_verificacion": digitoVerificacion ?? '',
        "address": address ?? '',
        "location": location ?? '',
        "subzone": subzone ?? '',
        "city": city ?? '',
        "state": state ?? '',
        "postal_code": postalCode ?? '',
        "country": country ?? '',
        "phone": phone ?? '',
        "email": email ?? '',
        "cf1": cf1 ?? '',
        "cf2": cf2 ?? '',
        "cf3": cf3 ?? '',
        "cf4": cf4 ?? '',
        "cf5": cf5 ?? '',
        "cf6": cf6 ?? '',
        "invoice_footer": invoiceFooter ?? '',
        "payment_term": paymentTerm ?? '',
        "logo": logo ?? '',
        "deposit_amount": depositAmount ?? '',
        "price_group_id": (priceGroupId ?? '0'),
        "price_group_name": priceGroupName ?? '',
        "id_partner": idPartner ?? '',
        "tipo_regimen": tipoRegimen ?? '',
        "city_code": cityCode ?? '',
        "status": status ?? '1',
        "birth_month": birthMonth ?? '',
        "birth_day": birthDay ?? '',
        "customer_only_for_pos": customerOnlyForPos ?? 1,
        "customer_seller_id_assigned": customerSellerIdAssigned ?? '',
        "customer_special_discount": customerSpecialDiscount ?? '',
        "fuente_retainer": fuenteRetainer ?? '',
        "iva_retainer": ivaRetainer ?? '',
        "ica_retainer": icaRetainer ?? '',
        "default_rete_fuente_id": defaultReteFuenteId ?? '',
        "default_rete_iva_id": defaultReteIvaId ?? '',
        "default_rete_ica_id": defaultReteIcaId ?? '',
        "default_rete_other_id": defaultReteOtherId ?? '',
        "customer_payment_type": customerPaymentType ?? '',
        "customer_credit_limit": customerCreditLimit ?? '',
        "customer_payment_term": customerPaymentTerm ?? '',
        "customer_validate_min_base_retention":
            customerValidateMinBaseRetention ?? '',
        "gender": gender ?? '',
        "logo_square": logoSquare ?? '',
        "tax_exempt_customer": taxExemptCustomer ?? '',
        "initial_accounting_balance_transferred":
            initialAccountingBalanceTransferred ?? '',
        "customer_profile_photo": customerProfilePhoto ?? '',
        "supplier_type": supplierType ?? '',
        "note": note ?? '',
        // "last_update": lastUpdate,
      };

  @override
  String toString() => capitalizeText(name ?? company ?? firstName ?? '');
}
