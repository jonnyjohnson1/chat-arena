enum SpacyModel { small, med, large, trf }

String getSpacyModelString(SpacyModel model) {
  switch (model) {
    case SpacyModel.small:
      return "en_core_web_sm";
    case SpacyModel.med:
      return "en_core_web_md";
    case SpacyModel.large:
      return "en_core_web_lg";
    case SpacyModel.trf:
      return "en_core_web_trf";
    default:
      return "en_core_web_sm"; // default case
  }
}

String getSimpleSpacyModelString(SpacyModel model) {
  switch (model) {
    case SpacyModel.small:
      return "small";
    case SpacyModel.med:
      return "med";
    case SpacyModel.large:
      return "large";
    case SpacyModel.trf:
      return "trf";
    default:
      return "small"; // default case
  }
}
