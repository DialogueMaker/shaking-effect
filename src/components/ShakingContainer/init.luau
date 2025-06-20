--!strict

local TweenService = game:GetService("TweenService");

local packages = script.Parent.Parent.Parent.roblox_packages;
local React = require(packages.react);
local DialogueMakerTypes = require(packages.DialogueMakerTypes);
local useContentSize = require(script.hooks.useContentSize);
local useIterativeContent = require(packages.useIterativeContent);

type ExecutionProperties = DialogueMakerTypes.ExecutionProperties;
type Page = DialogueMakerTypes.Page;

export type ShakingEffectProperties = {
  intensity: number?;
  frequency: number?;
  rotation: number?;
  content: Page;
}

local function ShakingContainer(properties: ShakingEffectProperties & {executionProperties: ExecutionProperties})

  local intensity = properties.intensity or 2;
  local frequency = properties.frequency or 0.05;
  local rotation = properties.rotation or 0;
  local content = properties.content;

  local executionProperties = properties.executionProperties;
  local client = executionProperties.client;
  local shouldSkip = executionProperties.shouldSkip;
  local skipPageSignal = executionProperties.skipPageSignal;
  local layoutOrder = executionProperties.layoutOrder or 1;
  local onCompleted = executionProperties.onCompleted;
  local createTextElement = executionProperties.createTextElement;

  local iterativeContent = useIterativeContent(content, client, skipPageSignal, shouldSkip, createTextElement, onCompleted);
  local textContainerRef = React.useRef(nil :: GuiObject?);
  local contentSize = useContentSize(textContainerRef);

  React.useEffect(function(): ()

    local textContainer = textContainerRef.current;
    if textContainer then

      local shakingTask = task.spawn(function()

        while task.wait(frequency) do

          local xOffset = math.random(-intensity, intensity);
          local yOffset = math.random(-intensity, intensity);

          TweenService:Create(textContainer, TweenInfo.new(frequency), {
            Position = UDim2.new(0, xOffset, 0, yOffset);
            Rotation = math.random(-rotation, rotation);
          }):Play();
          
        end
      
      end);

      return function()
        
        task.cancel(shakingTask);
        
      end;
    
    end

  end, {intensity, frequency});

  return React.createElement("Frame", {
    AutomaticSize = if contentSize then Enum.AutomaticSize.None else Enum.AutomaticSize.XY;
    BackgroundTransparency = 1;
    Size = if contentSize then UDim2.fromOffset(contentSize.X, contentSize.Y) else UDim2.new();
    LayoutOrder = layoutOrder;
  }, {
    TextContainer = React.createElement("Frame", {
      BackgroundTransparency = 1;
      AutomaticSize = if contentSize then Enum.AutomaticSize.None else Enum.AutomaticSize.XY;
      Size = UDim2.fromScale(1, 1);
      ref = textContainerRef; -- Used on a child because the position won't change if the parent is affected by UIListLayout.
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder;
        FillDirection = Enum.FillDirection.Horizontal;
        Wraps = true;
      });
      IterativeContent = React.createElement(React.Fragment, {}, iterativeContent);
    });
  });

end;

return React.memo(ShakingContainer);