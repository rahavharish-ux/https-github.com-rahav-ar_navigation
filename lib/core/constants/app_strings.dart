/// Centralized user-facing copy. Kept in one place so it's easy to audit
/// and can be swapped for a real localization solution later without
/// hunting through widget files.
class AppStrings {
  const AppStrings._();

  static const appName = 'TN AR NAV';
  static const appTagline = 'AR Navigation for Tamil Nadu';
  static const appTitle = 'TN AR Navigation';

  // Onboarding
  static const onboardTitle1 = 'Navigate the world differently.';
  static const onboardBody1 =
      'Get real-time GPS-guided directions built for Tamil Nadu roads and landmarks.';
  static const onboardTitle2 = 'See directions in the real world.';
  static const onboardBody2 =
      'Point your camera and see AR guidance overlaid on the world around you.';
  static const onboardTitle3 = 'Live navigation with AR guidance.';
  static const onboardBody3 =
      'We use GPS, camera, and motion sensors together to keep you on track.';
  static const onboardSkip = 'Skip';
  static const onboardNext = 'Next';
  static const onboardGetStarted = 'Get Started';

  // Home
  static const homeGreeting = 'Where to, today?';
  static const searchHint = 'Where do you want to go?';
  static const quickActionHome = 'Home';
  static const quickActionWork = 'Work';
  static const quickActionRecent = 'Recent';
  static const quickActionSaved = 'Saved';
  static const arNavigation = 'AR Navigation';
  static const arNavigationComingSoon =
      'Arrives once AR navigation (Phase 10) is built.';
  static const comingSoonQuickAction =
      'Saved & recent places arrive in a later phase';

  // Route preview
  static const startNavigation = 'Start Navigation';
  static const routeModeUnsupported =
      "Real routing for this travel mode isn't available in this "
      'development environment yet — try Driving.';
  static const routeFailedMessage =
      "Couldn't calculate a route right now. Check your connection and "
      'try again.';
  static const routeNeedsLocation =
      'Get your location first to see a route to this place.';

  // Navigation
  static const navigationArrivedTitle = "You've arrived";
  static const navigationArrivedBody = 'You have arrived at your destination.';
  static const navigationDone = 'Done';
  static const navigationPause = 'Pause';
  static const navigationResume = 'Resume';
  static const navigationStop = 'Stop';
  static const navigationOffRoute = "You're off the route.";
  static const navigationWrongDirection =
      "You're heading the wrong way. Recalculating your route…";
  static const navigationRecalculating = 'Recalculating your route…';
  static const navigationPaused = 'Navigation paused';
  static const navigationErrorMessage =
      "Couldn't recalculate your route. Check your connection.";

  // Search
  static const searchNoResults = 'No places found. Try a different search.';
  static const searchFailedMessage =
      "Couldn't search right now. Check your connection and try again.";
  static const searchPrompt = 'Search for a place, landmark, or address.';
  static const recentSearchesTitle = 'Recent';
  static const clearAll = 'Clear all';

  // Location
  static const locationServiceDisabled =
      'Location services are turned off. Please enable them to continue.';
  static const locationPermissionDenied =
      'Location permission is needed to show you on the map.';
  static const locationPermissionDeniedForever =
      'Location permission was denied. Enable it in Settings to continue.';
  static const locationGenericError = "Couldn't get your location right now.";
  static const locationOpenSettings = 'Open Settings';
  static const locationEnable = 'Enable';
  static const diagnosticsTitle = 'Developer Diagnostics';
  static const diagnosticsTooltip = 'Developer diagnostics';

  // Camera (Phase 9)
  static const cameraPreviewTitle = 'Camera Preview';
  static const cameraPreviewButton = 'Preview camera';
  static const cameraStarting = 'Starting the camera…';
  static const cameraNoOverlayNote =
      'Live camera feed only — AR guidance overlays arrive in Phase 10.';
  static const cameraPermissionDenied =
      'Camera permission is needed for AR navigation. Enable it in system '
      'settings, then try again.';
  static const cameraUnavailable =
      "This device doesn't have a usable camera. The rest of the app "
      "doesn't need one — only AR navigation (Phase 10) will.";
  static const cameraGenericError = "Couldn't start the camera right now.";
  static const cameraTryAgain = 'Try again';
  static const cameraStop = 'Stop';

  // Vision (Phase 13)
  static const visionTitle = 'Computer Vision';
  static const visionPreviewButton = 'Preview vision';
  static const visionScanText = 'Scan text';
  static const visionLabelScene = 'Label scene';
  static const visionIdlePrompt =
      'Point the camera at a street sign or scene, then choose an action '
      'below.';
  static const visionNoTextFound = 'No text detected in that frame.';
  static const visionNoLabelsFound = 'No labels detected in that frame.';
  static const visionFailedMessage = "Couldn't analyze that frame right now.";
  static const visionUnavailable =
      "On-device text/scene recognition isn't available on this platform.";

  // Auth (Phase 14)
  static const signInTitle = 'Sign In';
  static const signUpTitle = 'Create Account';
  static const emailLabel = 'Email';
  static const passwordLabel = 'Password';
  static const signInButton = 'Sign In';
  static const signUpButton = 'Create Account';
  static const signOutButton = 'Sign Out';
  static const switchToSignUp = "Don't have an account? Create one";
  static const switchToSignIn = 'Already have an account? Sign in';
  static const authNotConfigured =
      'No backend is configured yet. See SETUP.md to connect a Supabase '
      'project.';
  static const authEmailConfirmationRequired =
      'Check your email to confirm your account, then sign in.';
  static const accountTooltip = 'Account';
  static const accountTitle = 'Account';
  static const accountSignedInAsPrefix = 'Signed in as ';
  static const signInFailedMessage =
      "Couldn't sign in. Check your email and password and try again.";
  static const signUpFailedMessage = "Couldn't create your account. Try again.";

  // Saved places (Phase 14)
  static const savedPlacesTitle = 'Saved Places';
  static const savedPlacesEmpty =
      "You haven't saved any places yet. Search for a destination and "
      'save it from the route preview screen.';
  static const savedPlacesSignInPrompt = 'Sign in to save and view places.';
  static const savedPlacesFailedMessage =
      "Couldn't load your saved places right now.";
  static const savePlaceButton = 'Save this place';
  static const placeSaved = 'Place saved.';
  static const savePlaceFailedMessage = "Couldn't save this place right now.";
  static const removeSavedPlace = 'Remove';
}
