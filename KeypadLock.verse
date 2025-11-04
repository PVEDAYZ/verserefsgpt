
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors/NamedColors }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }


KeypadLock := class():

    UnlockCode : string 
    LockDevice : lock_device 
    ControllerVisibility : logic
    ToMessage<localizes>(String : string) : message = "{String}"

    Image_376: button = button{
        Slot:=button_slot:
            Widget:= texture_block:
                DefaultImage := UIElements.Digipad_1,
                DefaultHorizontalTiling := image_tiling.Stretch,
                DefaultVerticalTiling := image_tiling.Stretch,
                DefaultDesiredSize := vector2{X := 104.5,Y := 70.0}
    }
    Image_564: button = button{
        Slot:=button_slot:
            Widget:= texture_block:
                DefaultImage := UIElements.Digipad_2,
                DefaultHorizontalTiling := image_tiling.Stretch,
                DefaultVerticalTiling := image_tiling.Stretch,
                DefaultDesiredSize := vector2{X := 104.5,Y := 70.0}
    }
    Image_679: button = button{
        Slot:=button_slot:
            Widget:= texture_block:
                DefaultImage := UIElements.Digipad_3,
                DefaultHorizontalTiling := image_tiling.Stretch,
                DefaultVerticalTiling := image_tiling.Stretch,
                DefaultDesiredSize := vector2{X := 104.5,Y := 70.0}
    }
    Image: button = button{
        Slot:=button_slot:
            Widget:= texture_block:
                DefaultImage := UIElements.Digipad_4,
                DefaultHorizontalTiling := image_tiling.Stretch,
                DefaultVerticalTiling := image_tiling.Stretch,
                DefaultDesiredSize := vector2{X := 104.5,Y := 70.0}
    }
    Image_1: button = button{
        Slot:=button_slot:
            Widget:= texture_block:
                DefaultImage := UIElements.Digipad_5,
                DefaultHorizontalTiling := image_tiling.Stretch,
                DefaultVerticalTiling := image_tiling.Stretch,
                DefaultDesiredSize := vector2{X := 104.5,Y := 70.0}
    }
    Image_2: button = button{
        Slot:=button_slot:
            Widget:= texture_block:
                DefaultImage := UIElements.Digipad_6,
                DefaultHorizontalTiling := image_tiling.Stretch,
                DefaultVerticalTiling := image_tiling.Stretch,
                DefaultDesiredSize := vector2{X := 104.5,Y := 70.0}
    }
    Image_3: button = button{
        Slot:=button_slot:
            Widget:= texture_block:
                DefaultImage := UIElements.Digipad_7,
                DefaultHorizontalTiling := image_tiling.Stretch,
                DefaultVerticalTiling := image_tiling.Stretch,
                DefaultDesiredSize := vector2{X := 104.5,Y := 70.0}
    }
    Image_4: button = button{
        Slot:=button_slot:
            Widget:= texture_block:
                DefaultImage := UIElements.Digipad_8,
                DefaultHorizontalTiling := image_tiling.Stretch,
                DefaultVerticalTiling := image_tiling.Stretch,
                DefaultDesiredSize := vector2{X := 104.5,Y := 70.0}
    }
    Image_5: button = button{
        Slot:=button_slot:
            Widget:= texture_block:
                DefaultImage := UIElements.Digipad_9,
                DefaultHorizontalTiling := image_tiling.Stretch,
                DefaultVerticalTiling := image_tiling.Stretch,
                DefaultDesiredSize := vector2{X := 104.5,Y := 70.0}
    }
    Image_6: button = button{
        Slot:=button_slot:
            Widget:= texture_block:
                DefaultImage := UIElements.Digipad_0,
                DefaultHorizontalTiling := image_tiling.Stretch,
                DefaultVerticalTiling := image_tiling.Stretch,
                DefaultDesiredSize := vector2{X := 104.5,Y := 70.0}
    }
    Image_7: button = button{
        Slot:=button_slot:
            Widget:= texture_block:
                DefaultImage := UIElements.DigiScreen_Enter,
                DefaultHorizontalTiling := image_tiling.Stretch,
                DefaultVerticalTiling := image_tiling.Stretch,
                DefaultDesiredSize := vector2{X := 207.632614,Y := 70.0}
    }
    Image_851: button = button{
        Slot:=button_slot:
            Widget:= texture_block:
                DefaultImage := UIElements.Digipad_Cancel,
                DefaultHorizontalTiling := image_tiling.Stretch,
                DefaultVerticalTiling := image_tiling.Stretch,
                DefaultDesiredSize := vector2{X := 375.0,Y := 70.0}
    }


    Image_133: texture_block = texture_block{
        DefaultImage := UIElements.DigiBackground,
        DefaultHorizontalTiling := image_tiling.Stretch,
        DefaultVerticalTiling := image_tiling.Stretch,
        DefaultDesiredSize := vector2{X := 625.0,Y := 763.0}
    }
    Image_264: texture_block = texture_block{
        DefaultImage := UIElements.DigiScreen_InsertCode,
        DefaultHorizontalTiling := image_tiling.Stretch,
        DefaultVerticalTiling := image_tiling.Stretch,
        DefaultDesiredSize := vector2{X := 517.0,Y := 149.0}
    }
    Overlay_929: overlay = overlay{}
    UEFN_TextBlock_C: text_block = text_block{DefaultTextColor := color{R:=1.0, G:=1.0, B:=1.0}}
    Overlay_2731: overlay = overlay{}
    Overlay_768: overlay = overlay{}
    
    UEFN_Button_Quiet_C: button_quiet = button_quiet{}
    Overlay_1309: overlay = overlay{}
    ColorBlock: color_block = color_block{}
    Overlay_876: overlay = overlay{}
    
    UEFN_Button_Quiet_C_1: button_quiet = button_quiet{}
    Overlay: overlay = overlay{}
    Overlay_1480: overlay = overlay{}
    
    UEFN_Button_Quiet_C_2: button_quiet = button_quiet{}
    Overlay_1: overlay = overlay{}
    Overlay_1572: overlay = overlay{}
    StackBox_326: stack_box = stack_box{Orientation := orientation.Horizontal}
    
    UEFN_Button_Quiet_C_3: button_quiet = button_quiet{}
    Overlay_2: overlay = overlay{}
    Overlay_1735: overlay = overlay{}
    
    UEFN_Button_Quiet_C_4: button_quiet = button_quiet{}
    Overlay_3: overlay = overlay{}
    Overlay_1826: overlay = overlay{}
    
    UEFN_Button_Quiet_C_5: button_quiet = button_quiet{}
    Overlay_4: overlay = overlay{}
    Overlay_1953: overlay = overlay{}
    StackBox: stack_box = stack_box{Orientation := orientation.Horizontal}
    
    UEFN_Button_Quiet_C_6: button_quiet = button_quiet{}
    Overlay_5: overlay = overlay{}
    Overlay_2061: overlay = overlay{}
   
    UEFN_Button_Quiet_C_7: button_quiet = button_quiet{}
    Overlay_6: overlay = overlay{}
    Overlay_2756: overlay = overlay{}
    
    UEFN_Button_Quiet_C_8: button_quiet = button_quiet{}
    Overlay_7: overlay = overlay{}
    Overlay_2876: overlay = overlay{}
    StackBox_1: stack_box = stack_box{Orientation := orientation.Horizontal}
    
    UEFN_Button_Quiet_C_9: button_quiet = button_quiet{}
    Overlay_8: overlay = overlay{}
    Overlay_1171: overlay = overlay{}

    UEFN_Button_Quiet_C_10: button_quiet = button_quiet{}
    Overlay_9: overlay = overlay{}
    Overlay_1310: overlay = overlay{}
    StackBox_2: stack_box = stack_box{Orientation := orientation.Horizontal}
    
    UEFN_Button_Quiet_C_11: button_quiet = button_quiet{}
    Overlay_10: overlay = overlay{}
    Overlay_1458: overlay = overlay{}
    StackBox_463: stack_box = stack_box{Orientation := orientation.Vertical}
    StackBox_142: stack_box = stack_box{Orientation := orientation.Vertical}
    Overlay_411: overlay = overlay{}
    Overlay_82: overlay = overlay{}
    var CanvasPanel_28: canvas = canvas{}
    var CodeAttempt : string = ""

    AddUI(Agent : agent) : void=
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):

            set CanvasPanel_28 = Init()
            PlayerUI.AddWidget(CanvasPanel_28 , player_ui_slot{InputMode := ui_input_mode.All})

    Button1(Agent:widget_message):void=
            Image_264.SetImage(UIElements.DigiScreen_Empty)
            set CodeAttempt += "1"
            UEFN_TextBlock_C.SetText(ToMessage(CodeAttempt))
    Button2(Agent:widget_message):void=
            Image_264.SetImage(UIElements.DigiScreen_Empty)
            set CodeAttempt += "2"
            UEFN_TextBlock_C.SetText(ToMessage(CodeAttempt))
    Button3(Agent:widget_message):void=
            Image_264.SetImage(UIElements.DigiScreen_Empty)
            set CodeAttempt += "3"
            UEFN_TextBlock_C.SetText(ToMessage(CodeAttempt))
    Button4(Agent:widget_message):void=
            Image_264.SetImage(UIElements.DigiScreen_Empty)
            set CodeAttempt += "4"
            UEFN_TextBlock_C.SetText(ToMessage(CodeAttempt))
    Button5(Agent:widget_message):void=
            Image_264.SetImage(UIElements.DigiScreen_Empty)
            set CodeAttempt += "5"
            UEFN_TextBlock_C.SetText(ToMessage(CodeAttempt))
    Button6(Agent:widget_message):void=
            Image_264.SetImage(UIElements.DigiScreen_Empty)
            set CodeAttempt += "6"
            UEFN_TextBlock_C.SetText(ToMessage(CodeAttempt))
    Button7(Agent:widget_message):void=
            Image_264.SetImage(UIElements.DigiScreen_Empty)
            set CodeAttempt += "7"
            UEFN_TextBlock_C.SetText(ToMessage(CodeAttempt))
    Button8(Agent:widget_message):void=
            Image_264.SetImage(UIElements.DigiScreen_Empty)
            set CodeAttempt += "8"
            UEFN_TextBlock_C.SetText(ToMessage(CodeAttempt))
    Button9(Agent:widget_message):void=
            Image_264.SetImage(UIElements.DigiScreen_Empty)
            set CodeAttempt += "9"
            UEFN_TextBlock_C.SetText(ToMessage(CodeAttempt))
    Button0(Agent:widget_message):void=
            Image_264.SetImage(UIElements.DigiScreen_Empty)
            set CodeAttempt += "0"
            UEFN_TextBlock_C.SetText(ToMessage(CodeAttempt))

    CancelDigicode(Agent:widget_message):void=
        Player := Agent.Player
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(CanvasPanel_28)

    InitCheckCode(Agent:widget_message):void=
        spawn{CheckCode(Agent)}

    CheckCode(Agent:widget_message)<suspends>:void=


        if(CodeAttempt = UnlockCode):
            Print("Le code est bon")
            set CodeAttempt = ""
            UEFN_TextBlock_C.SetText(ToMessage(CodeAttempt))
            Image_264.SetImage(UIElements.DigiScreen_Correct)
            LockDevice.Unlock(Agent.Player)
            Sleep(3.0)
            if(PlayerUI := GetPlayerUI[Agent.Player]):
                PlayerUI.RemoveWidget(CanvasPanel_28)
        else:
            set CodeAttempt = ""
            UEFN_TextBlock_C.SetText(ToMessage(CodeAttempt))
            Image_264.SetImage(UIElements.DigiScreen_Error)
            Print("Code Pas bon")


    Init(): canvas =

        Image_376.OnClick().Subscribe(Button1)
        UEFN_Button_Quiet_C.OnClick().Subscribe(Button1)

        Image_564.OnClick().Subscribe(Button2)
        UEFN_Button_Quiet_C_1.OnClick().Subscribe(Button2)

        Image_679.OnClick().Subscribe(Button3)
        UEFN_Button_Quiet_C_2.OnClick().Subscribe(Button3)

        Image.OnClick().Subscribe(Button4)
        UEFN_Button_Quiet_C_3.OnClick().Subscribe(Button4)
        
        Image_1.OnClick().Subscribe(Button5)
        UEFN_Button_Quiet_C_4.OnClick().Subscribe(Button5)

        Image_2.OnClick().Subscribe(Button6)
        UEFN_Button_Quiet_C_5.OnClick().Subscribe(Button6)

        Image_3.OnClick().Subscribe(Button7)
        UEFN_Button_Quiet_C_6.OnClick().Subscribe(Button7)
        
        Image_4.OnClick().Subscribe(Button8)
        UEFN_Button_Quiet_C_7.OnClick().Subscribe(Button8)

        Image_5.OnClick().Subscribe(Button9)
        UEFN_Button_Quiet_C_8.OnClick().Subscribe(Button9)
        
        Image_6.OnClick().Subscribe(Button0)
        UEFN_Button_Quiet_C_9.OnClick().Subscribe(Button0)
        
        Image_7.OnClick().Subscribe(InitCheckCode)
        UEFN_Button_Quiet_C_10.OnClick().Subscribe(InitCheckCode)

        Image_851.OnClick().Subscribe(CancelDigicode)
        UEFN_Button_Quiet_C_11.OnClick().Subscribe(CancelDigicode)

        for (Slot: array{
            overlay_slot{
                Widget := Image_264,
                HorizontalAlignment:= horizontal_alignment.Center,
                VerticalAlignment:= vertical_alignment.Center,
                Padding:= margin{Top := 40.0,Bottom := 45.0}
            }
        }){Overlay_929.AddWidget(Slot)}

        for (Slot: array{
            overlay_slot{
                Widget := UEFN_TextBlock_C,
                HorizontalAlignment:= horizontal_alignment.Center,
                VerticalAlignment:= vertical_alignment.Top,
                Padding:= margin{Bottom := 15.0}
            }
        }){Overlay_2731.AddWidget(Slot)}

        for (Slot: array{
            overlay_slot{
                Widget := Overlay_929,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            },
            overlay_slot{
                Widget := Overlay_2731,
                HorizontalAlignment:= horizontal_alignment.Center,
                VerticalAlignment:= vertical_alignment.Center
            }
        }){Overlay_768.AddWidget(Slot)}

        
        # }){Overlay_1309.AddWidget(Slot)}

        if(ControllerVisibility?):
            for (Slot: array{
                overlay_slot{
                    Widget := UEFN_Button_Quiet_C,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_1309.AddWidget(Slot)}
            

            for (Slot: array{
                overlay_slot{
                    # kixov
                    Widget := Image_376,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill,
                    Padding:= margin{Right := 10.0}
                },
                overlay_slot{
                    Widget := Overlay_1309,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_876.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := UEFN_Button_Quiet_C_1,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay.AddWidget(Slot)}
    
            for (Slot: array{
                overlay_slot{
                    Widget := Image_564,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill
                },
                overlay_slot{
                    Widget := Overlay,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_1480.AddWidget(Slot)}

                
            for (Slot: array{
                overlay_slot{
                    Widget := UEFN_Button_Quiet_C_2,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_1.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := Image_679,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill,
                    Padding:= margin{Left := 10.0}
                },
                overlay_slot{
                    Widget := Overlay_1,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_1572.AddWidget(Slot)}
            
            
        else:
            for (Slot: array{
                overlay_slot{
                    # kixov
                    Widget := Image_376,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill,
                    Padding:= margin{Right := 10.0}
                }
            }){Overlay_876.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := Image_564,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill
                }
            }){Overlay_1480.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := Image_679,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill,
                    Padding:= margin{Left := 10.0}
                }
            }){Overlay_1572.AddWidget(Slot)}

            # ///////////////////////////////////

       


        for (Slot: array{
            stack_box_slot{
                Widget := Overlay_876,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            },
            stack_box_slot{
                Widget := Overlay_1480,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            },
            stack_box_slot{
                Widget := Overlay_1572,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
        }){StackBox_326.AddWidget(Slot)}


        if(ControllerVisibility?):

            for (Slot: array{
                overlay_slot{
                    Widget := UEFN_Button_Quiet_C_3,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_2.AddWidget(Slot)}
    
            for (Slot: array{
                overlay_slot{
                    Widget := Image,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill,
                    Padding:= margin{Right := 10.0}
                },
                overlay_slot{
                    Widget := Overlay_2,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_1735.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := UEFN_Button_Quiet_C_4,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_3.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := Image_1,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill
                },
                overlay_slot{
                    Widget := Overlay_3,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_1826.AddWidget(Slot)}

                
            for (Slot: array{
                overlay_slot{
                    Widget := UEFN_Button_Quiet_C_5,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_4.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := Image_2,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill,
                    Padding:= margin{Left := 10.0}
                },
                overlay_slot{
                    Widget := Overlay_4,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_1953.AddWidget(Slot)}

        else:

            for (Slot: array{
                overlay_slot{
                    Widget := Image,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill,
                    Padding:= margin{Right := 10.0}
                }
            }){Overlay_1735.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := Image_1,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill
                }
            }){Overlay_1826.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := Image_2,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill,
                    Padding:= margin{Left := 10.0}
                }
                
            }){Overlay_1953.AddWidget(Slot)}



        


        for (Slot: array{
            stack_box_slot{
                Widget := Overlay_1735,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            },
            stack_box_slot{
                Widget := Overlay_1826,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            },
            stack_box_slot{
                Widget := Overlay_1953,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
        }){StackBox.AddWidget(Slot)}

        if(ControllerVisibility?):


            for (Slot: array{
                overlay_slot{
                    Widget := UEFN_Button_Quiet_C_6,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_5.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := Image_3,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill,
                    Padding:= margin{Right := 10.0}
                },
                overlay_slot{
                    Widget := Overlay_5,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_2061.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := UEFN_Button_Quiet_C_7,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_6.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := Image_4,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill
                },
                overlay_slot{
                    Widget := Overlay_6,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_2756.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := UEFN_Button_Quiet_C_8,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_7.AddWidget(Slot)}
    
            for (Slot: array{
                overlay_slot{
                    Widget := Image_5,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill,
                    Padding:= margin{Left := 10.0}
                },
                overlay_slot{
                    Widget := Overlay_7,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_2876.AddWidget(Slot)}
        else:
            for (Slot: array{
                overlay_slot{
                    Widget := Image_3,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill,
                    Padding:= margin{Right := 10.0}
                }
            }){Overlay_2061.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := Image_4,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill
                }
            }){Overlay_2756.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := Image_5,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill,
                    Padding:= margin{Left := 10.0}
                }
            }){Overlay_2876.AddWidget(Slot)}


       

        for (Slot: array{
            stack_box_slot{
                Widget := Overlay_2061,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            },
            stack_box_slot{
                Widget := Overlay_2756,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            },
            stack_box_slot{
                Widget := Overlay_2876,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
        }){StackBox_1.AddWidget(Slot)}

        if(ControllerVisibility?):

            for (Slot: array{
                overlay_slot{
                    Widget := UEFN_Button_Quiet_C_9,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_8.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := Image_6,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill,
                    Padding:= margin{Right := 10.0}
                },
                overlay_slot{
                    Widget := Overlay_8,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_1171.AddWidget(Slot)}

            for (Slot: array{
            overlay_slot{
                Widget := UEFN_Button_Quiet_C_10,
                HorizontalAlignment:= horizontal_alignment.Center,
                VerticalAlignment:= vertical_alignment.Center
            }
            }){Overlay_9.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := Image_7,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill,
                    Padding:= margin{Left := 10.0}
                },
                overlay_slot{
                    Widget := Overlay_9,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_1310.AddWidget(Slot)}
        else:
            for (Slot: array{
                overlay_slot{
                    Widget := Image_6,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill,
                    Padding:= margin{Right := 10.0}
                }
            }){Overlay_1171.AddWidget(Slot)}

            for (Slot: array{
                overlay_slot{
                    Widget := Image_7,
                    HorizontalAlignment:= horizontal_alignment.Fill,
                    VerticalAlignment:= vertical_alignment.Fill,
                    Padding:= margin{Left := 10.0}
                }
            }){Overlay_1310.AddWidget(Slot)}

        

        for (Slot: array{
            stack_box_slot{
                Widget := Overlay_1171,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            },
            stack_box_slot{
                Widget := Overlay_1310,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
        }){StackBox_2.AddWidget(Slot)}

        if(ControllerVisibility?):
            for (Slot: array{
                overlay_slot{
                    Widget := UEFN_Button_Quiet_C_11,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_10.AddWidget(Slot)}

        
            for (Slot: array{
                overlay_slot{
                    Widget := Image_851,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                },
                overlay_slot{
                    Widget := Overlay_10,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_1458.AddWidget(Slot)}
        else:
            for (Slot: array{
                overlay_slot{
                    Widget := Image_851,
                    HorizontalAlignment:= horizontal_alignment.Center,
                    VerticalAlignment:= vertical_alignment.Center
                }
            }){Overlay_1458.AddWidget(Slot)}


        for (Slot: array{
            stack_box_slot{
                Widget := StackBox_326,
                Padding:= margin{Bottom := 15.0},
                HorizontalAlignment:= horizontal_alignment.Center,
                VerticalAlignment:= vertical_alignment.Fill
            },
            stack_box_slot{
                Widget := StackBox,
                Padding:= margin{Bottom := 15.0},
                HorizontalAlignment:= horizontal_alignment.Center,
                VerticalAlignment:= vertical_alignment.Fill
            },
            stack_box_slot{
                Widget := StackBox_1,
                Padding:= margin{Bottom := 15.0},
                HorizontalAlignment:= horizontal_alignment.Center,
                VerticalAlignment:= vertical_alignment.Fill
            },
            stack_box_slot{
                Widget := StackBox_2,
                Padding:= margin{Bottom := 15.0},
                HorizontalAlignment:= horizontal_alignment.Center,
                VerticalAlignment:= vertical_alignment.Fill
            },
            stack_box_slot{
                Widget := Overlay_1458,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
        }){StackBox_463.AddWidget(Slot)}

        for (Slot: array{
            stack_box_slot{
                Widget := Overlay_768,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            },
            stack_box_slot{
                Widget := StackBox_463,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
        }){StackBox_142.AddWidget(Slot)}

        for (Slot: array{
            overlay_slot{
                Widget := StackBox_142,
                HorizontalAlignment:= horizontal_alignment.Fill,
                VerticalAlignment:= vertical_alignment.Fill
            }
        }){Overlay_411.AddWidget(Slot)}

        for (Slot: array{
            overlay_slot{
                Widget := Image_133,
                HorizontalAlignment:= horizontal_alignment.Left,
                VerticalAlignment:= vertical_alignment.Top
            },
            overlay_slot{
                Widget := Overlay_411,
                HorizontalAlignment:= horizontal_alignment.Center,
                VerticalAlignment:= vertical_alignment.Center
            }
        }){Overlay_82.AddWidget(Slot)}

        for (Slot: array{
            canvas_slot{
                Widget := Overlay_82,
                SizeToContent:= false,
                Offsets:= margin{Right := 620.0,Bottom := 760.0},
                Anchors:= anchors{Minimum := vector2{X := 0.5,Y := 0.5},Maximum := vector2{X := 0.5,Y := 0.5}},
                Alignment:= vector2{X := 0.5,Y := 0.5}
            }
        }){CanvasPanel_28.AddWidget(Slot)}
        CanvasPanel_28

    






KeypadLockDevice := class(creative_device):

    @editable UnlockCode : string = "0000"
    @editable OpenUIKeypadLockButton: button_device = button_device{}
    @editable LockDevice : lock_device = lock_device{}
    @editable ControllerVisibility: logic = false
   
    OnBegin<override>()<suspends>:void=
    
        OpenUIKeypadLockButton.InteractedWithEvent.Subscribe(OpenUI)
      
        
    OpenUI(Agent:agent):void=
        var NewUIDigicode : KeypadLock = KeypadLock{UnlockCode:= UnlockCode, LockDevice:= LockDevice, ControllerVisibility:= ControllerVisibility}
        
        NewUIDigicode.AddUI(Agent)
