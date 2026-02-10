CLASS zcl_la02_ce_so_query DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_la02_ce_so_query IMPLEMENTATION.

  METHOD if_rap_query_provider~select.
    DATA lt_result TYPE STANDARD TABLE OF zla02_ce_salesorder.

    " Obtener paginación (requerido por el framework)
    DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
    DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).

    " Por ahora retornamos tabla vacía - esto es solo para el LIST
    " La creación no usa este método

    IF io_request->is_data_requested( ).
      io_response->set_data( lt_result ).
    ENDIF.

    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( 0 ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
