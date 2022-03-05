module Dropdowns exposing (main)

import Browser
import Browser.Dom
import Html exposing (Html)
import Html.Attributes as Attr
import Layers
import Layers.Dropdown
import Layers.Modal



-- MAIN - the entrypoint to the Elm application


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- 1️⃣  First we define a custom type for all the overlays we might need to show


type Item
    = DropdownLeft
    | DropdownRight
    | NestedDropdown
    | NestedModal



-- INIT - the initial state of the app


type alias Model =
    { -- 2️⃣  This will keep track of open overlays for us
      layers : Layers.Model Item
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { -- 3️⃣  We use `Layer.init` to initialize our app (with no open overlays)
        layers = Layers.init
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = -- 4️⃣  This will handle internal messages from our overlay layer (open/close/etc)
      GotLayersMsg (Layers.Msg Item)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotLayersMsg layersMsg ->
            -- 5️⃣  When we get a message, the `Layers.update` function will
            --     convert it into a ( Model, Cmd Msg ) for us!
            Layers.update
                { msg = layersMsg
                , model = model.layers
                , toAppMsg = GotLayersMsg
                , toAppModel = \newLayers -> { model | layers = newLayers }
                }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    -- 6️⃣  Use `Layers.view` to wrap your normal `view` function.
    Layers.view
        { model = model.layers
        , toAppMsg = GotLayersMsg
        , viewAppLayer = viewAppLayer model
        , viewLayerItem = viewLayerItem model
        }


viewAppLayer : Model -> Html Msg
viewAppLayer model =
    -- 7️⃣  Use `Layers.viewButton` to create a button that opens your modal.
    Html.div []
        [ Layers.viewButton
            { item = DropdownLeft
            , model = model.layers
            , toAppMsg = GotLayersMsg
            }
            [ Attr.style "margin" "1rem" ]
            [ Html.text "Open a dropdown" ]
        , Layers.viewButton
            { item = DropdownRight
            , model = model.layers
            , toAppMsg = GotLayersMsg
            }
            [ Attr.style "margin" "1rem" ]
            [ Html.text "Open a nested dropdown" ]
        ]



-- 8️⃣  Define a way to view items


viewLayerItem : Model -> Item -> Browser.Dom.Element -> Html Msg
viewLayerItem model item parent =
    let
        -- You can customize the look-and-feel of your dropdowns too!
        viewDropdownMenuWith : List (Html Msg) -> Html Msg
        viewDropdownMenuWith =
            Html.div
                [ Attr.style "background" "white"
                , Attr.style "box-shadow" "0 4px 8px rgba(0,0,0,0.15)"
                , Attr.style "margin-top" "8px"
                , Attr.style "padding" "16px 12px"
                , Attr.style "min-width" "200px"
                , Attr.style "border-radius" "4px"
                , Attr.style "border" "solid 1px #ccc"
                ]
    in
    case item of
        DropdownLeft ->
            Layers.Dropdown.viewLeft parent
                (viewDropdownMenuWith
                    [ Html.text "Hello, world! This is in a dropdown!" ]
                )

        DropdownRight ->
            Layers.Dropdown.viewRight parent
                (viewDropdownMenuWith
                    [ Layers.viewButton
                        { item = NestedDropdown
                        , model = model.layers
                        , toAppMsg = GotLayersMsg
                        }
                        []
                        [ Html.text "Open one more dropdown" ]
                    ]
                )

        NestedDropdown ->
            Layers.Dropdown.viewLeft parent
                (viewDropdownMenuWith
                    [ Html.text "Wait..."
                    , Layers.viewButton
                        { item = NestedModal
                        , model = model.layers
                        , toAppMsg = GotLayersMsg
                        }
                        []
                        [ Html.text "You can have modals nested in dropdowns??" ]
                    ]
                )

        NestedModal ->
            Layers.Modal.viewCentered
                (Html.div
                    [ Attr.style "background" "white"
                    , Attr.style "box-shadow" "0 4px 8px rgba(0,0,0,0.15)"
                    , Attr.style "margin-top" "8px"
                    , Attr.style "padding" "16px 12px"
                    , Attr.style "min-width" "200px"
                    , Attr.style "border-radius" "4px"
                    , Attr.style "border" "solid 1px #ccc"
                    ]
                    [ Html.text "Wow, this is wild." ]
                )
