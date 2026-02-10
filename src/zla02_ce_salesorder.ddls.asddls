@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order with Attachment'
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
@Metadata.allowExtensions: true
define root view entity ZLA02_CE_SALESORDER
  as select from zla02_dt_stage

{
  key uuid           as uuid,
      doc_type       as docType,
      sales_org      as salesOrg,
      distr_chan     as distrChan,
      division       as division,
      sold_to        as soldTo,
      test_run       as testRun,
      filename       as filename,
      @Semantics.mimeType: true
      mimetype       as mimetype,
      @Semantics.largeObject: {
        mimeType: 'mimetype',
        fileName: 'filename',
        contentDispositionPreference: #INLINE
      }
      attachment     as attachment,
      sales_order_id as salesOrderId,
      created_at     as createdAt
}
