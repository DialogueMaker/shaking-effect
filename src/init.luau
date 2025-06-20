--!strict
-- This effect pauses a message for a certain amount of time.
-- This is helpful for when you want to draw emphasis to some text.
-- 
-- Programmer: Christian Toney
-- © 2025 Dialogue Maker Group

local packages = script.Parent.roblox_packages;
local Effect = require(packages.Effect);
local DialogueMakerTypes = require(packages.DialogueMakerTypes);
local React = require(packages.react);
local ShakingContainer = require(script.components.ShakingContainer);

type ShakingEffectProperties = ShakingContainer.ShakingEffectProperties;
type RunEffectFunction = DialogueMakerTypes.RunEffectFunction;

local ShakingEffect = {};

function ShakingEffect.new(properties: ShakingEffectProperties)
  
  assert(not properties.intensity or properties.intensity == math.floor(properties.intensity), "Expected intensity to be an integer.");
  
  local run: RunEffectFunction = function(self, executionProperties)

    return React.createElement(ShakingContainer, {
      frequency = properties.frequency;
      intensity = properties.intensity;
      key = executionProperties.key;
      content = properties.content;
      executionProperties = executionProperties;
    });

  end;
  
  local effect = Effect.new({
    name = "ShakingEffect";
    run = run;
  });

  return effect;

end;

return ShakingEffect;