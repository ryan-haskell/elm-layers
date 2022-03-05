module Layers.Modal exposing (viewCentered)

import Html exposing (Html)
import Html.Attributes as Attr


viewCentered : Html msg -> Html msg
viewCentered content =
    Html.div [ Attr.class "elm-layers__modal elm-layers__modal--center" ] [ content ]
