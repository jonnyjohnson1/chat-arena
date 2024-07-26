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
