module ThermalModelsHelper
  def dd_models
    [
      {value: "dd_39p2_86", label: "39.2°F / 86F (4°C / 30°C)"},
      {value: "dd_41_86",   label: "41°F / 86F (5°C / 30°C)"},
      {value: "dd_41_none", label: "41°F / none (5°C / none)"},
      {value: "dd_42p8_86", label: "42.8°F / 86°F (6°C / 30°C)"},
      {value: "dd_45_86",   label: "45°F / 86°F (7.2°C / 30°C)"},
      {value: "dd_45_none", label: "45°F / none (7.2°C / none)"},
      {value: "dd_48_none", label: "48°F / none (9°C / none)"},
      {value: "dd_50_86",   label: "50°F / 86°F (10°C / 30°C)"},
      {value: "dd_50_none", label: "50°F / none (10°C / none)"}
    ]
  end

  def dd_labels
    dd_models.collect { |m| [m[:label], m[:value]] }
  end
end
