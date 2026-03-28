resource "volterra_app_firewall" "mcn-default-waf" {
  name      = "${local.setup-init.student.name}-mcn-default-waf"
  namespace = local.setup-init.xC.namespace

  # Mode: Blocking
  blocking = true

  # Detection Settings
  detection_settings {
    signature_selection_setting {
      default_attack_type_settings        = true
      high_medium_low_accuracy_signatures = true
    }

    disable_suppression     = true
    disable_staging         = true
    enable_threat_campaigns = true

    default_bot_setting = true

    violations_view {
      name    = "VIOL_EVASION_APACHE_WHITESPACE"
      enabled = true
    }
    violations_view {
      name    = "VIOL_HTTP_PROTOCOL_BAD_HTTP_VERSION"
      enabled = true
    }
    violations_view {
      name    = "VIOL_HTTP_PROTOCOL_BAD_HOST_HEADER_VALUE"
      enabled = true
    }
    violations_view {
      name    = "VIOL_HTTP_PROTOCOL_BAD_MULTIPART_FORMDATA_REQUEST_PARSING"
      enabled = false
    }
    violations_view {
      name    = "VIOL_EVASION_BAD_UNESCAPE"
      enabled = false
    }
    violations_view {
      name    = "VIOL_HTTP_PROTOCOL_BAD_MULTIPART_PARAMETERS_PARSING"
      enabled = true
    }
    violations_view {
      name    = "VIOL_EVASION_BARE_BYTE_DECODING"
      enabled = true
    }
    violations_view {
      name    = "VIOL_HTTP_PROTOCOL_BODY_IN_GET_OR_HEAD_REQUEST"
      enabled = false
    }
    violations_view {
      name    = "VIOL_HTTP_PROTOCOL_CRLF_CHARACTERS_BEFORE_REQUEST_START"
      enabled = true
    }
    violations_view {
      name    = "VIOL_HTTP_PROTOCOL_CONTENT_LENGTH_SHOULD_BE_A_POSITIVE_NUMBER"
      enabled = true
    }
    violations_view {
      name    = "VIOL_COOKIE_MODIFIED"
      enabled = true
    }
    violations_view {
      name    = "VIOL_COOKIE_MALFORMED"
      enabled = false
    }
    violations_view {
      name    = "VIOL_EVASION_DIRECTORY_TRAVERSALS"
      enabled = true
    }
    violations_view {
      name    = "VIOL_FILE_UPLOAD"
      enabled = true
    }
    violations_view {
      name    = "VIOL_FILE_UPLOAD_IN_BODY"
      enabled = true
    }
    violations_view {
      name    = "VIOL_ENCODING"
      enabled = false
    }
    violations_view {
      name    = "VIOL_HTTP_PROTOCOL_HIGH_ASCII_CHARACTERS_IN_HEADERS"
      enabled = false
    }
    violations_view {
      name    = "VIOL_EVASION_IIS_BACKSLASHES"
      enabled = true
    }
    violations_view {
      name    = "VIOL_EVASION_IIS_UNICODE_CODEPOINTS"
      enabled = true
    }
    violations_view {
      name    = "VIOL_FILETYPE"
      enabled = true
    }
    violations_view {
      name    = "VIOL_METHOD"
      enabled = true
    }
    violations_view {
      name    = "VIOL_JSON_MALFORMED"
      enabled = true
    }
    violations_view {
      name    = "VIOL_XML_MALFORMED"
      enabled = true
    }
    violations_view {
      name    = "VIOL_MALFORMED_REQUEST"
      enabled = true
    }
    violations_view {
      name    = "VIOL_MANDATORY_HEADER"
      enabled = true
    }
    violations_view {
      name    = "VIOL_ASM_COOKIE_MODIFIED"
      enabled = true
    }
    violations_view {
      name    = "VIOL_HTTP_PROTOCOL_MULTIPLE_HOST_HEADERS"
      enabled = true
    }
    violations_view {
      name    = "VIOL_EVASION_MULTIPLE_DECODING"
      enabled = true
    }
    violations_view {
      name    = "VIOL_HTTP_PROTOCOL_NO_HOST_HEADER_IN_HTTP_1_1_REQUEST"
      enabled = true
    }
    violations_view {
      name    = "VIOL_HTTP_PROTOCOL_NULL_IN_REQUEST"
      enabled = true
    }
    violations_view {
      name    = "VIOL_EVASION_PERCENT_U_DECODING"
      enabled = true
    }
    violations_view {
      name    = "VIOL_REQUEST_MAX_LENGTH"
      enabled = true
    }
    violations_view {
      name    = "VIOL_HTTP_PROTOCOL_SEVERAL_CONTENT_LENGTH_HEADERS"
      enabled = true
    }
    violations_view {
      name    = "VIOL_HTTP_PROTOCOL_UNPARSABLE_REQUEST_CONTENT"
      enabled = true
    }
  }

  # Response codes
  allow_all_response_codes = true

  # Anonymization
  default_anonymization = true

  # Blocking Page
  blocking_page {
    blocking_page = "string:///PCFET0NUWVBFIGh0bWw+CjxodG1sIGxhbmc9ImVuIj4KPGhlYWQ+CjxtZXRhIGNoYXJzZXQ9IlVURi04Ij4KPG1ldGEgbmFtZT0idmlld3BvcnQiIGNvbnRlbnQ9IndpZHRoPWRldmljZS13aWR0aCwgaW5pdGlhbC1zY2FsZT0xLjAiPgo8dGl0bGU+QWNjZXNzIERlbmllZDwvdGl0bGU+Cgo8c3R5bGU+CiAgICBib2R5IHsKICAgICAgICBtYXJnaW46IDA7CiAgICAgICAgZm9udC1mYW1pbHk6ICJTZWdvZSBVSSIsIEFyaWFsLCBzYW5zLXNlcmlmOwogICAgICAgIGJhY2tncm91bmQ6IGxpbmVhci1ncmFkaWVudCgxMzVkZWcsICMxZTI5M2IsICMwZjE3MmEpOwogICAgICAgIGNvbG9yOiAjZTJlOGYwOwogICAgICAgIGRpc3BsYXk6IGZsZXg7CiAgICAgICAganVzdGlmeS1jb250ZW50OiBjZW50ZXI7CiAgICAgICAgYWxpZ24taXRlbXM6IGNlbnRlcjsKICAgICAgICBoZWlnaHQ6IDEwMHZoOwogICAgfQoKICAgIC5jYXJkIHsKICAgICAgICBiYWNrZ3JvdW5kOiAjMWUyOTNiOwogICAgICAgIHBhZGRpbmc6IDQwcHg7CiAgICAgICAgYm9yZGVyLXJhZGl1czogMTZweDsKICAgICAgICBib3gtc2hhZG93OiAwIDEwcHggMzBweCByZ2JhKDAsMCwwLDAuNSk7CiAgICAgICAgdGV4dC1hbGlnbjogY2VudGVyOwogICAgICAgIG1heC13aWR0aDogNTAwcHg7CiAgICAgICAgd2lkdGg6IDkwJTsKICAgIH0KCiAgICAuY2FyZCBpbWcgewogICAgICAgIG1heC13aWR0aDogMjIwcHg7CiAgICAgICAgbWFyZ2luLWJvdHRvbTogMjBweDsKICAgIH0KCiAgICBoMSB7CiAgICAgICAgbWFyZ2luOiAwIDAgMTBweDsKICAgICAgICBmb250LXNpemU6IDI4cHg7CiAgICAgICAgY29sb3I6ICNmODcxNzE7CiAgICB9CgogICAgcCB7CiAgICAgICAgZm9udC1zaXplOiAxNnB4OwogICAgICAgIGxpbmUtaGVpZ2h0OiAxLjU7CiAgICAgICAgY29sb3I6ICNjYmQ1ZjU7CiAgICB9CgogICAgLnJlcS1pZCB7CiAgICAgICAgbWFyZ2luLXRvcDogMjBweDsKICAgICAgICBmb250LXNpemU6IDE0cHg7CiAgICAgICAgY29sb3I6ICM5NGEzYjg7CiAgICAgICAgYmFja2dyb3VuZDogIzBmMTcyYTsKICAgICAgICBwYWRkaW5nOiAxMHB4OwogICAgICAgIGJvcmRlci1yYWRpdXM6IDhweDsKICAgICAgICB3b3JkLWJyZWFrOiBicmVhay1hbGw7CiAgICB9CgogICAgYSB7CiAgICAgICAgZGlzcGxheTogaW5saW5lLWJsb2NrOwogICAgICAgIG1hcmdpbi10b3A6IDI1cHg7CiAgICAgICAgcGFkZGluZzogMTBweCAyMHB4OwogICAgICAgIGJhY2tncm91bmQ6ICMzYjgyZjY7CiAgICAgICAgY29sb3I6IHdoaXRlOwogICAgICAgIHRleHQtZGVjb3JhdGlvbjogbm9uZTsKICAgICAgICBib3JkZXItcmFkaXVzOiA4cHg7CiAgICAgICAgdHJhbnNpdGlvbjogMC4yczsKICAgIH0KCiAgICBhOmhvdmVyIHsKICAgICAgICBiYWNrZ3JvdW5kOiAjMjU2M2ViOwogICAgfQo8L3N0eWxlPgo8L2hlYWQ+Cgo8Ym9keT4KCjxkaXYgY2xhc3M9ImNhcmQiPgoKICAgIDxpbWcgc3JjPSJodHRwczovL2dpdGh1Yi5jb20vZGUxY2hrMW5kL3hDLW1jbi1kZW1vL3Jhdy9tYWluL2RvY3MvaW1hZ2VzL21pc2MvcGV3LXBldy5wbmciIGFsdD0iQmxvY2tlZCI+CgogICAgPGgxPkFjY2VzcyBEZW5pZWQ8L2gxPgoKICAgIDxwPgogICAgICAgIFRoZSByZXF1ZXN0ZWQgVVJMIGhhcyBiZWVuIGJsb2NrZWQuPGJyPgogICAgICAgIFBsZWFzZSBjb250YWN0IHlvdXIgYWRtaW5pc3RyYXRvciBpZiB5b3UgYmVsaWV2ZSB0aGlzIGlzIGFuIGVycm9yLgogICAgPC9wPgoKICAgIDxkaXYgY2xhc3M9InJlcS1pZCI+CiAgICAgICAgUmVxdWVzdCBJRDoge3tyZXF1ZXN0X2lkfX0KICAgIDwvZGl2PgoKICAgIDxhIGhyZWY9ImphdmFzY3JpcHQ6aGlzdG9yeS5iYWNrKCkiPkdvIEJhY2s8L2E+Cgo8L2Rpdj4KCjwvYm9keT4KPC9odG1sPgo=CAgIDxpbWcgc3JjPSJodHRwczovL2dpdGh1Yi5jb20vZGUxY2hrMW5kL3hDLW1jbi1kZW1vL3Jhdy9tYWluL2RvY3MvaW1hZ2VzL21pc2MvcGV3LXBldy5wbmciIGFsdD0iQmxvY2tlZCI+CgogICAgPGgxPkFjY2VzcyBEZW5pZWQ8L2gxPgoKICAgIDxwPgogICAgICAgIFRoZSByZXF1ZXN0ZWQgVVJMIGhhcyBiZWVuIGJsb2NrZWQuPGJyPgogICAgICAgIFBsZWFzZSBjb250YWN0IHlvdXIgYWRtaW5pc3RyYXRvciBpZiB5b3UgYmVsaWV2ZSB0aGlzIGlzIGFuIGVycm9yLgogICAgPC9wPgoKICAgIDxkaXYgY2xhc3M9InJlcS1pZCI+CiAgICAgICAgUmVxdWVzdCBJRDoge3tyZXF1ZXN0X2lkfX0KICAgIDwvZGl2PgoKICAgIDxhIGhyZWY9ImphdmFzY3JpcHQ6aGlzdG9yeS5iYWNrKCkiPkdvIEJhY2s8L2E+Cgo8L2Rpdj4KCjwvYm9keT4KPC9odG1sPg=="
    response_code = "OK"
  }

  # AI-powered risk-based analysis
  enable_ai_enhancements {
    mitigate_high_risk_action = true
  }
}
