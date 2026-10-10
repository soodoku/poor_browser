browser_tokens <- function(agent) {
  if (!is.character(agent)) stop("agent must be a character vector")
  ua <- tolower(trimws(agent))
  token <- function(pattern) {
    hit <- regexpr(pattern, ua, perl = TRUE)
    out <- rep(NA_character_, length(ua))
    found <- !is.na(ua) & hit > 0L
    out[found] <- regmatches(ua, hit)
    out
  }
  ie <- token("\\bmsie [0-9]+(?:\\.[0-9]+)*")
  ff <- token("\\bfirefox/[0-9]+(?:\\.[0-9]+)*")
  ie_major <- as.integer(sub("msie ([0-9]+).*", "\\1", ie))
  ff_major <- as.integer(sub("firefox/([0-9]+).*", "\\1", ff))
  ff_minor <- suppressWarnings(as.integer(sub("firefox/[0-9]+\\.([0-9]+).*", "\\1", ff)))
  family <- rep("Unknown", length(ua))
  family[grepl("applewebkit/", ua)] <- "WebKit"
  family[grepl("chrome/", ua)] <- "Chrome"
  family[grepl("seamonkey/|netscape/", ua)] <- "Other Gecko"
  family[!is.na(ff)] <- "Firefox"
  family[!is.na(ie)] <- "IE"
  family[grepl("opera[ /]|opr/", ua)] <- "Opera"
  old <- rep(NA, length(ua))
  other <- family %in% c("WebKit", "Chrome", "Other Gecko", "Opera")
  old[other] <- FALSE
  is_ie <- family == "IE"
  is_ff <- family == "Firefox"
  old[is_ie] <- ie_major[is_ie] <= 7L
  old[is_ff] <- ff_major[is_ff] < 3L |
    (ff_major[is_ff] == 3L & ff_minor[is_ff] == 0L)
  compatibility <- is_ie & ie_major == 7L & grepl("\\btrident/4\\.0\\b", ua)
  installed_old <- old
  installed_old[compatibility] <- FALSE
  category <- ifelse(is.na(old), "Unknown", ifelse(old, "Legacy token", "Other recognized"))
  category[compatibility] <- "IE8 compatibility"
  data.frame(family, old, installed_old, compatibility, category,
    at_width_limit = !is.na(ua) & nchar(ua) >= 100L
  )
}

historical_browser <- function(clean_agent) {
  grepl("msie4|98|iphone|symbian|msie5|msie6|msie7|firefox30", clean_agent)
}
