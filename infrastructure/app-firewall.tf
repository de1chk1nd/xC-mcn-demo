resource "volterra_app_firewall" "mcn-default-waf" {
  name      = "${local.setup-init.student.name}-mcn-default-waf"
  namespace = local.setup-init.xC.namespace

  # Mode: Blocking
  blocking = true

  # Blocking Page (loaded from HTML file, base64-encoded at plan time)
  blocking_page {
    blocking_page = "string:///${base64encode(file("${path.module}/etc/waf/blocking-page.html"))}"
    response_code = "OK"
  }

  # NOTE: Advanced settings (detection_settings, violations_view, enable_ai_enhancements)
  # are configured via xC Console after initial deployment.
  # The Terraform provider creates the base policy reliably; extended settings
  # applied via Terraform may require a manual save in the Console to propagate.
}
