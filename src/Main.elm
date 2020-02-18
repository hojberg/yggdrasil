module Main exposing (main)

import Browser
import Browser.Events
import Browser.Navigation as Nav
import Html exposing (Html, a, article, div, h1, h2, header, nav, span, text)
import Html.Attributes exposing (attribute, class, href, src, type_)
import Html.Events exposing (onClick)
import Url



-- MAIN


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- Realm


type Realm
    = EmberApp String
    | ReactApp String


urlToRealm : Url.Url -> Result String Realm
urlToRealm url =
    let
        str =
            Url.toString url
    in
    if String.startsWith "/ember-app" url.path then
        url.path
            |> String.replace "ember-app" ""
            |> EmberApp
            |> Ok

    else if String.startsWith "/react-app" url.path then
        url.path
            |> String.replace "react-app" ""
            |> ReactApp
            |> Ok

    else
        Err ("Could not match URL '" ++ str ++ "' to any Realm")


realmResultToActiveRealm : Result String Realm -> ActiveRealm
realmResultToActiveRealm realm =
    case realm of
        Ok r ->
            Success r

        Err e ->
            Failure e



-- Model


type ActiveRealm
    = Loading
    | Failure String
    | Success Realm


type alias Model =
    { activeRealm : ActiveRealm
    , navKey : Nav.Key
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd msg )
init _ url navKey =
    let
        realm =
            url |> urlToRealm |> realmResultToActiveRealm
    in
    ( { navKey = navKey, activeRealm = realm }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.navKey url.path )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                realm =
                    url |> urlToRealm |> realmResultToActiveRealm
            in
            ( { model | activeRealm = realm }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
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
                        EmberApp path ->
                            Html.node "ember-app" [ attribute "path" path ] []

                        ReactApp path ->
                            Html.node "react-app" [ attribute "path" path ] []
    in
    { title = "Yggdrasil"
    , body =
        [ div []
            [ header []
                [ h1 [] [ text "Main Header" ]
                , nav []
                    [ a [ href "/ember-app" ] [ text "Ember App" ]
                    , span [] [ text " | " ]
                    , a [ href "/react-app" ] [ text "React App" ]
                    , span [] [ text " | " ]
                    , a [ href "/react-app/sub" ] [ text "React App / Sub" ]
                    ]
                ]
            , article [] [ content ]
            ]
        ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
