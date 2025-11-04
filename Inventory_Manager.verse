
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }


InventorySlot := class<concrete>():
    @editable ItemConditional : conditional_button_device = conditional_button_device{}
    @editable ItemTracker : tracker_device = tracker_device{}
    @editable GranterIDX : int = 0
    var MainItemGranter : item_granter_device = item_granter_device{}
    @editable ItemBB : billboard_device = billboard_device{}
    @editable ItemRemover : item_remover_device = item_remover_device{}
    @editable StoreButton : button_device = button_device{}
    @editable ExtractButton : button_device = button_device{}


    StringToMessage<localizes>(String : string) : message = "{String}"
    
    Store(Agent:agent) : void=
        CurrentStashedAmount := ItemTracker.GetValue(Agent)
        CurrentlyHeldAmount := ItemConditional.GetItemCount(Agent , 0)
        NewStashedAmount := CurrentStashedAmount + CurrentlyHeldAmount
        ItemTracker.SetValue(Agent, NewStashedAmount)
        ItemBB.SetText(StringToMessage("{NewStashedAmount}"))
        ItemRemover.Remove(Agent)

    Extract(Agent : agent) : void=
        CurrentStashedAmount := ItemTracker.GetValue(Agent)
        if(CurrentStashedAmount > 0):
            NewStashedAmount := CurrentStashedAmount - 1
            ItemTracker.SetValue(Agent, NewStashedAmount)
            ItemBB.SetText(StringToMessage("{NewStashedAmount}"))
            MainItemGranter.GrantItemIndex(Agent, GranterIDX)


    Update(Agent:agent) : void=
        CurrentStashedAmount := ItemTracker.GetValue(Agent)
        ItemBB.SetText(StringToMessage("{CurrentStashedAmount}"))




Inventory_Manager := class(creative_device):

    
    @editable MainItemGranter : item_granter_device = item_granter_device{}
    @editable InventorySlots : []InventorySlot = array{}


    OnBegin<override>()<suspends>:void=
        for(ISlot : InventorySlots):
            set ISlot.MainItemGranter = MainItemGranter
            ISlot.StoreButton.InteractedWithEvent.Subscribe(ISlot.Store)
            ISlot.ExtractButton.InteractedWithEvent.Subscribe(ISlot.Extract)
            for(Player : GetPlayspace().GetPlayers()){ISlot.Update(Player)}
            GetPlayspace().PlayerAddedEvent().Subscribe(ISlot.Update)


        