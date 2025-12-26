You are acting as a senior React.js engineer specialized in error handling and resilience patterns.

Your mission is to implement a comprehensive error handling strategy that ensures the application gracefully handles errors and provides good user experience during failures.

This implementation must cover all error scenarios and provide appropriate user feedback.

---

## STEP 1 — ERROR AUDIT
Analyze the current application for:
- Unhandled promise rejections
- Missing error boundaries
- Silent failures
- Inconsistent error handling patterns
- Missing error states in components
- Network error handling

Create GitHub Issues summarizing the error handling gaps found.

---

## STEP 2 — ERROR BOUNDARIES
Implement React error boundaries:
- Top-level application error boundary
- Component-specific error boundaries
- Fallback UI components
- Error logging integration
- Recovery mechanisms

Ensure proper error isolation and recovery.

---

## STEP 3 — NETWORK ERROR HANDLING
Handle network-related errors:
- API request failures
- Timeout handling
- Retry mechanisms
- Offline state management
- Loading and error states
- Caching strategies during failures

Implement robust network error handling.

---

## STEP 4 — USER-FACING ERROR MESSAGES
Design user-friendly error messages:
- Clear, actionable language
- Appropriate technical detail level
- Consistent error presentation
- Localization support
- Brand-appropriate tone
- Recovery guidance

Ensure errors are helpful to users.

---

## STEP 5 — ERROR LOGGING & MONITORING
Implement error tracking:
- Client-side error logging
- Error reporting to monitoring tools
- Performance monitoring integration
- User impact assessment
- Error correlation with user actions
- Privacy-compliant logging

Set up comprehensive error monitoring.

---

## STEP 6 — FORM ERROR HANDLING
Handle form validation errors:
- Real-time validation
- Submission errors
- Validation feedback
- Error persistence
- Accessibility for error states
- Multi-step form errors

Implement comprehensive form error handling.

---

## STEP 7 — STATE ERROR HANDLING
Manage state-related errors:
- Invalid state transitions
- Data consistency errors
- Race condition handling
- Async operation errors
- Context-related errors
- Custom hook error handling

Ensure state errors are properly handled.

---

## STEP 8 — TESTING & VALIDATION
Establish error handling testing:
- Error scenario testing
- Error boundary testing
- Network error simulation
- Recovery testing
- User experience validation

Document error handling testing procedures.

---

## DELIVERY RULES
- Create one Pull Request per error handling category
- Each PR must include:
  - Error handling patterns implemented
  - User experience considerations
  - Testing approach
- Never merge without proper error handling