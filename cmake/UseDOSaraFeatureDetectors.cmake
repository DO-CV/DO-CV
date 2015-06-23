include_directories(
  ${DO_Sara_INCLUDE_DIR}
  ${DO_Sara_ThirdParty_DIR}/eigen)

if (DO_USE_FROM_SOURCE)
  get_property(DO_Sara_FeatureDetectors_ADDED GLOBAL PROPERTY _DO_Sara_FeatureDetectors_INCLUDED)
  if (NOT DO_Sara_FeaturesDetectors_ADDED)
    do_glob_directory(${DO_Sara_SOURCE_DIR}/FeatureDetectors)
    do_create_common_variables("FeatureDetectors")
    do_set_internal_dependencies("FeatureDetectors" "Core;Features;Graphics")
    do_generate_library("FeaturesDetectors")
  endif ()
endif ()