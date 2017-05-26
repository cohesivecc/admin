# Developed by Neal White, 07/18/2008
# <b>Description:</b> Simple library of regular expressions to address common use cases.
module RegexLibrary

  # USERNAME: begins with a letter, letters and numbers only, case insensitve, 3-20 characters
  USERNAME          = /^[A-Z][A-Z0-9]{3,20}$/i
  USERNAME_MESSAGE  = 'must start with a letter, may only contain letters and numbers, and must be between 3 and 20 characters long'
  USERNAME_URL      = /[A-Z][A-Z0-9]{3,20}/i

  # DISPLAY_NAME: begins with a letter, letters, numbers, whitespace, and underscores, case insensitive, 1-15 characters
  DISPLAY_NAME  = /^[A-Z][A-Z0-9\s_]{1,15}$/i

  # EMAIL: standard email format (joe@yahoo.com etc.)
  EMAIL         = /(\A(\s*)\Z)|(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z)/i
  EMAIL_MESSAGE = 'must be valid email format (joe@yahoo.com etc.)'

  # POST_CODE: 5 or 10 characters, all digits *except* for the single hyphen (50613 or 50613-1234)
  POST_CODE     = /^\d{5}(-\d{4})?$/

  # PHONE: US phone number format, (123) 456-7890
  # PHONE         = /^\(\d{3}\) \d{3}-\d{4}$/

  # PHONE: US phone number (10 digits including area code, not starting with 1 or 0)
  PHONE         = /^[2-9]\d{9}$/
  PHONE_LENGTH  = 10
  PHONE_MESSAGE = 'must be full 10 digit phone number (including area code) and contain only digits'

  # URL: valid HTTP or HTTPS URL format
  URL           = /(^$)|(^(http|https):\/\/[a-zA-Z0-9]+([-.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}(([0-9]{1,5})?\/.*)?$)/
  URL_MESSAGE   = 'must be a valid URL (please include the http:// or https:// prefix)'

  # URL_SLUG: for objects that use URL slug as the to_param, starts with a letter
  # letters, digits, underscore and hyphen, 2-80 characters
  URL_SLUG          = /\A[a-zA-Z0-9][a-zA-Z0-9_-]{1,79}\z/i
  URL_SLUG_MESSAGE  = 'must start with a letter or number, may only contain letters, digits, underscores or hyphen characters, must be between 2 and 80 characters long'
  URL_SLUG_LENGTH   = 2..80

  # Unix-style timestamp - within reason we can assume it must start with a '1' and only be 10 characters long
  TIMESTAMP         = /1[\d]{9}/

  # Password requirements
  PASSWORD          = /(?=^.{8,}$)((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z])/
  PASSWORD_MESSAGE  = 'must be at least 8 characters long, and must contain at least one upper-case, one lower-case, and one number or special character'

  PASSWORD_CONFIRMATION_MESSAGE = "doesn't match password"
end
