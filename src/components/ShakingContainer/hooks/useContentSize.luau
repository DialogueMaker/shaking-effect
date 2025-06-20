--!strict

local packages = script.Parent.Parent.Parent.Parent.Parent.roblox_packages;
local React = require(packages.react);

local function useContentSize(textContainerRef: React.Ref<GuiObject>): Vector2?

  assert(typeof(textContainerRef) == "table", "Expected textContainerRef to be a table.");
  
  local contentSize: Vector2?, setContentSize = React.useState(nil :: Vector2?);

  React.useEffect(function(): ()
  
    local textContainer = textContainerRef.current;
    if textContainer then

      local function updateContentSize()
        
        local size = textContainer.AbsoluteSize;
        setContentSize(size);

      end;

      local absoluteSizeConnection = textContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateContentSize);
      updateContentSize();

      return function()

        absoluteSizeConnection:Disconnect();
        setContentSize(nil);

      end;
      
    end;

  end, {});

  return contentSize;

end;

return useContentSize;
