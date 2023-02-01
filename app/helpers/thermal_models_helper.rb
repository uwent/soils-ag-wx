module ThermalModelsHelper
  def dd_models
    [
      {value: "dd_32_none", label: "Base 32°F (0°C)"},
      {value: "dd_39p2_86", label: "Base 39.2°F, upper 86°F (4°C / 30°C)"},
      {value: "dd_41_none", label: "Base 41°F (5°C)"},
      {value: "dd_41_86", label: "Base 41°F, upper 86°F (5°C / 30°C)"},
      {value: "dd_42p8_86", label: "Base 42.8°F, upper 86°F (6°C / 30°C)"},
      {value: "dd_45_none", label: "Base 45°F (7.2°C)"},
      {value: "dd_45_86", label: "Base 45°F, upper 86°F (7.2°C / 30°C)"},
      {value: "dd_48_none", label: "Base 48°F (9°C)"},
      {value: "dd_50_none", label: "Base 50°F (10°C)"},
      {value: "dd_50_86", label: "Base 50°F, upper 86°F (10°C / 30°C)"}
    ]
  end

  def dd_labels
    dd_models.collect { |m| [m[:label], m[:value]] }
  end

  def dsv_models
    [
      {value: "potato_blight_dsv", label: "Late blight DSVs"},
      {value: "potato_p_days", label: "Early blight P-Days"},
      {value: "carrot_foliar_dsv", label: "Carrot foliar disease DSVs"},
      {value: "cercospora_div", label: "Cercospora leaf spot DSVs"}
    ]
  end

  def dsv_labels
    dsv_models.collect { |m| [m[:label], m[:value]] }
  end
end
