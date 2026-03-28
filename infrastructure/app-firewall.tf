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

  # Blocking Page (loaded from HTML file, base64-encoded at plan time)
  blocking_page {
    blocking_page = "string:///${base64encode(file("${path.module}/modules/regions/etc/waf/blocking-page.html"))}"
    response_code = "OK"
  }

  # AI-powered risk-based analysis
  enable_ai_enhancements {
    mitigate_high_risk_action = true
  }
}
