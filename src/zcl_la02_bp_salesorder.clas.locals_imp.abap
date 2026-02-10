CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_buffer,
             uuid       TYPE sysuuid_x16,
             doctype    TYPE auart,
             salesorg   TYPE vkorg,
             distrchan  TYPE vtweg,
             division   TYPE spart,
             soldto     TYPE kunnr,
             testrun    TYPE char1,
             filename   TYPE char255,
             mimetype   TYPE char128,
             attachment TYPE xstring,
           END OF ty_buffer.
    CLASS-DATA: mt_buffer TYPE STANDARD TABLE OF ty_buffer WITH EMPTY KEY.
ENDCLASS.

CLASS lhc_salesorder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys   REQUEST requested_authorizations FOR SalesOrder
      RESULT    result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE SalesOrder.
    METHODS prepareForSave FOR DETERMINE ON SAVE
      IMPORTING keys FOR SalesOrder~prepareForSave.
ENDCLASS.

CLASS lhc_salesorder IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).
      DATA(lv_uuid) = <entity>-uuid.
      IF lv_uuid IS INITIAL.
        lv_uuid = cl_system_uuid=>create_uuid_x16_static( ).
      ENDIF.
      APPEND VALUE #(
        %cid      = <entity>-%cid
        %key-uuid = lv_uuid
        %is_draft = <entity>-%is_draft
      ) TO mapped-salesorder.
    ENDLOOP.
  ENDMETHOD.

  METHOD prepareForSave.
    READ ENTITIES OF zla02_ce_salesorder IN LOCAL MODE
      ENTITY SalesOrder
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_salesorders).

    lcl_buffer=>mt_buffer = VALUE #( FOR ls IN lt_salesorders (
      uuid       = ls-uuid
      doctype    = ls-docType
      salesorg   = ls-salesOrg
      distrchan  = ls-distrChan
      division   = ls-division
      soldto     = ls-soldTo
      testrun    = ls-testRun
      filename   = ls-filename
      mimetype   = ls-mimetype
      attachment = ls-attachment
    ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_salesorder DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_salesorder IMPLEMENTATION.

  METHOD save_modified.

  DATA: lv_base64        TYPE string,
        lv_extension     TYPE string,
        lv_salesdoc      TYPE vbeln,
        lv_result        TYPE string,
        lv_attach_result TYPE string.

  LOOP AT lcl_buffer=>mt_buffer INTO DATA(ls_buffer).

    CLEAR lv_base64.
    IF ls_buffer-attachment IS NOT INITIAL.
      lv_base64 = cl_web_http_utility=>encode_x_base64( ls_buffer-attachment ).
    ENDIF.

    CLEAR lv_extension.
    IF ls_buffer-filename IS NOT INITIAL.
      DATA(lv_filename) = CONV string( ls_buffer-filename ).
      DATA(lv_last_dot) = find( val = lv_filename sub = '.' occ = -1 ).
      IF lv_last_dot >= 0.
        lv_extension = substring( val = lv_filename off = lv_last_dot + 1 ).
        lv_extension = to_upper( lv_extension ).
      ENDIF.
    ENDIF.

    CALL FUNCTION 'ZLA02_RFC_SO' DESTINATION 'NONE'
      EXPORTING
        iv_doc_type       = ls_buffer-doctype
        iv_sales_org      = ls_buffer-salesorg
        iv_distr_chan     = ls_buffer-distrchan
        iv_division       = ls_buffer-division
        iv_sold_to        = ls_buffer-soldto
        iv_test_run       = ls_buffer-testrun
        iv_filename       = ls_buffer-filename
        iv_file_extension = lv_extension
        iv_file_base64    = lv_base64
      IMPORTING
        ev_salesdoc       = lv_salesdoc
        ev_result         = lv_result
        ev_attach_result  = lv_attach_result
      EXCEPTIONS
        OTHERS            = 1.

    IF sy-subrc = 0 AND lv_salesdoc IS NOT INITIAL.
      reported-salesorder = VALUE #( (
        uuid = ls_buffer-uuid
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-success
          text     = |Sales Order { lv_salesdoc } created successfully|
        )
      ) ).
    ENDIF.

  ENDLOOP.

  CLEAR lcl_buffer=>mt_buffer.

ENDMETHOD.

ENDCLASS.
