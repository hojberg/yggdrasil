module Main exposing (ActiveRealm(..), Model, Msg(..), Realm(..), Url, init, update, urlToRealm, view)

import Browser
import Browser.Events
import Html exposing (Html, article, div, h1, h2, header, iframe, text)
import Html.Attributes exposing (class, src, type_)
import Html.Events exposing (onClick)


type alias Url =
    String



-- Realm


type Realm
    = AppOne Url
    | AppTwo Url


urlToRealm : Url -> Result String Realm
urlToRealm url =
    if String.startsWith "/app-one" url then
        Ok (AppOne url)

    else if String.startsWith "/app-two" url then
        Ok (AppTwo url)

    else
        Err ("Could not match URL '" ++ url ++ "' to any Realm")



-- Model


type ActiveRealm
    = Loading
    | Failure String
    | Success Realm


type alias Model =
    { activeRealm : ActiveRealm
    }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        url =
            "/app-one"

        realm =
            urlToRealm url
    in
    case realm of
        Ok r ->
            ( { activeRealm = Success r }, Cmd.none )

        Err e ->
            ( { activeRealm = Failure e }, Cmd.none )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        content =
            case model.activeRealm of
                Loading ->
                    h2 [] [ text "Loading" ]

                Failure _ ->
                    h2 [] [ text "Not found" ]

                Success realm ->
                    case realm of
                        AppOne _ ->
                            iframe [ src "./app1/index.html" ] []

                        AppTwo _ ->
                            iframe [ src "./app2/index.html" ] []
    in
    div []
        [ header [] [ h1 [] [ text "Main Header" ] ]
        , article [] [ content ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
