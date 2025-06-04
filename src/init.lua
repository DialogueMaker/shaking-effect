--!strict
-- This effect pauses a message for a certain amount of time.
-- This is helpful for when you want to draw emphasis to some text.
-- 
-- Programmer: Christian Toney
-- © 2025 Dialogue Maker Group

local packages = script.Parent.roblox_packages;
local DialogueContentFitter = require(packages.dialogue_content_fitter);
local Effect = require(packages.effect);
local DialogueMakerTypes = require(packages.dialogue_maker_types);
local React = require(packages.react);
local ShakingContainer = require(script.ShakingContainer);

type Bounds = DialogueMakerTypes.Bounds;
type ContinuePageFunction = DialogueMakerTypes.ContinuePageFunction;
type Effect = DialogueMakerTypes.Effect;
type ExecutionProperties = DialogueMakerTypes.ExecutionProperties;
type Page = DialogueMakerTypes.Page;
type ShakingEffectProperties = ShakingContainer.ShakingEffectProperties;
type RunEffectFunctionReturnValue = DialogueMakerTypes.RunEffectFunctionReturnValue;

local ShakingEffect = {};

function ShakingEffect.new(properties: ShakingEffectProperties): Effect
  
  assert(not properties.intensity or properties.intensity == math.floor(properties.intensity), "Expected intensity to be an integer.");
  
  local function fit(self: Effect, contentContainer: GuiObject, textLabel: TextLabel, pages: {Page}): (GuiObject, {Page}) 
    
    -- Since this effect is just animating simple text, we can fit the effect by 
    -- simulating the amount of space that the text would take up in the container by itself.

    -- In the future, this effect may support other content such as images or buttons.
    -- But for now, this is enough.
    local simulatedContentContainer, simulatedPages = DialogueContentFitter:fitText(properties.text, contentContainer, textLabel, pages);

    -- Replace the inserted strings with effects.
    for currentPageIndex = #pages, #simulatedPages do

      local initialComponentIndex = if currentPageIndex == #pages then #pages[#pages] + 1 else 1;
      local currentPage = simulatedPages[currentPageIndex];
      
      for currentComponentIndex = initialComponentIndex, #currentPage do

        local text = currentPage[currentComponentIndex];
        assert(typeof(text) == "string", "Expected text to be a string");

        currentPage[currentComponentIndex] = ShakingEffect.new({
          text = text;
          frequency = properties.frequency;
          intensity = properties.intensity;
        });

      end;

    end;

    return simulatedContentContainer, simulatedPages;
    
  end;

  local function run(self: Effect, executionProperties: ExecutionProperties): RunEffectFunctionReturnValue

    return React.createElement(ShakingContainer, {
      frequency = properties.frequency;
      intensity = properties.intensity;
      text = properties.text;
      layoutOrder = executionProperties.textComponentProperties.layoutOrder;
      key = executionProperties.key;
    }, {
      Message = React.createElement(executionProperties.textComponent, {
        skipPageEvent = executionProperties.skipPageEvent;
        text = properties.text;
        onComplete = executionProperties.continuePage;
        layoutOrder = 1;
        letterDelay = executionProperties.textComponentProperties.letterDelay;
        textSize = executionProperties.textComponentProperties.textSize;
      })
    });

  end;
  
  local effect = Effect.new({
    name = "ShakingEffect";
    fit = fit;
    run = run;
  });

  return effect;

end;

return ShakingEffect;