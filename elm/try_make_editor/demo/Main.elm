import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import Json.Decode as Json

import TextEditor as Editor
import TextEditor.Core as Core
import TextEditor.Commands as Commands
import TextEditor.Buffer as Buffer
import TextEditor.KeyBind as KeyBind

import SoftwareKeyboard

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }

type alias Model =
    { editor : Editor.Model
    , raw_buf : String

    , bgColor : { index : String, list : List String }
    , fgColor : { index : String, list : List String }
    , fontFamily : { index : String, list : List String }
    , fontSize : { index : String, list : List String }

    , swkeyboard : SoftwareKeyboard.Model
    }

type Msg
    = MoveForward
    | MoveBackword
    | MovePrevios
    | MoveNext
    | Backspace
    | Delete
    | Copy
    | Cut
    | Pasete
    | Undo
    | EditorMsg (Editor.Msg)
    | SetEventlogEnable Bool
    | ChangeBGColor String
    | ChangeFGColor String
    | ChangeFontFamily String
    | ChangeFontSize String
    | SWKeyboardMsg (SoftwareKeyboard.Msg)

init : (Model, Cmd Msg)
init =
    let
        (bm, bc) = Editor.init "editor-sample1" (KeyBind.basic ++ KeyBind.gates ++ KeyBind.emacsLike) ""
    in
        ( Model bm ""
              { index = "inherit", list = ["inherit", "black", "white", "linen", "dimgray", "whitesmoke", "midnightblue", "darkolivegreen", "darkslategray", "lavender"] }
              { index = "inherit", list = ["inherit", "black", "white", "aqua", "coral", "midnightblue", "darkslategray", "lavender", "palevioletred", "rosybrown"] }
              { index = "inherit", list = ["inherit", "cursive", "fantasy", "monospace", "sans-serif", "serif"] }
              { index = "inherit", list = ["inherit", "0.5em", "1em", "1.5em", "2em", "3em", "5em", "7em", "10em"] }
              SoftwareKeyboard.init
        , Cmd.map EditorMsg bc
        )



updateMap: Model -> (Editor.Model, Cmd Editor.Msg) -> (Model, Cmd Msg)
updateMap model (em, ec) =
    ( {model | editor = em}
    , Cmd.map EditorMsg ec
    )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        MoveForward ->
            updateMap model (Commands.moveForward model.editor)

        MoveBackword ->
            updateMap model (Commands.moveBackward model.editor)

        MovePrevios ->
            updateMap model (Commands.movePrevios model.editor)

        MoveNext ->
            updateMap model (Commands.moveNext model.editor)

        Backspace ->
            updateMap model (Commands.backspace model.editor)

        Delete ->
            updateMap model (Commands.delete model.editor)

        Copy ->
            updateMap model (Commands.copy model.editor)

        Cut ->
            updateMap model (Commands.cut model.editor)

        Pasete ->
            updateMap model (Commands.paste model.editor)

        Undo ->
            updateMap model (Commands.undo model.editor)

        SetEventlogEnable True ->
            let
                em = model.editor
            in
                ( { model
                      | editor = {em| event_log = Just []}
                  }
                , Cmd.none)

        SetEventlogEnable False ->
            let
                em = model.editor
            in
                ( { model
                      | editor = {em| event_log = Nothing}
                  }
                , Cmd.none)

        ChangeBGColor s ->
            ( { model
                  | bgColor = { index = s
                              , list = model.bgColor.list
                              }
              }
            , Cmd.none )

        ChangeFGColor s ->
            ( { model
                  | fgColor = { index = s
                              , list = model.fgColor.list
                              }
              }
            , Cmd.none )

        ChangeFontFamily s ->
            ( { model
                  | fontFamily = { index = s
                                 , list = model.fontFamily.list
                                 }
              }
            , Cmd.none )
        ChangeFontSize s ->
            ( { model
                  | fontSize = { index = s
                               , list = model.fontSize.list
                               }
              }
            , Cmd.none )


        -- ScenarioPage >> List
        EditorMsg msg ->
            let
                (m, c) = Editor.update msg model.editor
            in
                ( { model | editor = m}
                , Cmd.map EditorMsg c )


        SWKeyboardMsg swmsg ->
            let
                (kbd, edt) = SoftwareKeyboard.update swmsg model.swkeyboard model.editor
            in
                ( { model
                      | editor   = Tuple.first edt
                      , swkeyboard = Tuple.first kbd
                  }
                , Cmd.batch [ Cmd.map EditorMsg (Tuple.second edt)
                            , Cmd.map SWKeyboardMsg (Tuple.second kbd)
                            ]
                )

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Sub.map EditorMsg  (Editor.subscriptions model.editor) ]


view : Model -> Html Msg
view model =
    div [ style [ ("margin", "0"), ("padding", "0"), ("width", "100%"), ("height", "100%")
                , ("display", "flex"), ("flex-direction", "column")
                ]
        ]
        [ h1 [] [text "TextEditor Sample"]
        , styleConfig model
        , div [ style [ ("margin", "0"), ("padding", "0"), ("width", "100%"), ("height", "100%")
                      , ("overflow","hidden")
                      , ("flex-grow", "8")
                      , ("color", model.fgColor.index)
                      , ("background-color", model.bgColor.index)
                      , ("font-family", model.fontFamily.index)
                      , ("font-size", model.fontSize.index)
                      ]
              ]
              [ Html.map EditorMsg (Editor.view model.editor) ]
        , modeline model
        , controlPane model
        , debugPane model
        , Html.map SWKeyboardMsg (SoftwareKeyboard.view model.swkeyboard)
        ]

styleConfig : Model -> Html Msg
styleConfig model =
    div [ style [ ("display", "flex"), ("flex-direction", "row"), ("justify-content", "space-between"), ("align-items", "center")
                , ("height", "2em"), ("flex-grow", "2"), ("background-color", "lightsteelblue"), ("color", "snow")
                ]
        ]
        [ div [] [ span [] [text "background-color: "]
                 , selectList model.bgColor.index model.bgColor.list ChangeBGColor
                 ]
        , div [] [ span [] [text "color: "]
                 , selectList model.fgColor.index model.fgColor.list ChangeFGColor
                 ]
        , div [] [ span [] [text "font-family: "]
                 , selectList model.fontFamily.index model.fontFamily.list ChangeFontFamily
                 ]
        , div [] [ span [] [text "font-size: "]
                 , selectList model.fontSize.index model.fontSize.list ChangeFontSize
                 ]
        ]

selectList: String -> List String -> (String -> msg) -> Html msg
selectList idx values tagger =
    select [on "change" (Json.map tagger (Json.at ["target","value"] Json.string))]
        ( List.map
              (\ v -> option
                   [ value v , selected (idx == v)]
                   [ text v ]
              ) values
        )

modeline : Model -> Html msg
modeline model =
    let
        toCursorString    = \c -> "(" ++ (toString c.row) ++ ", " ++ (toString c.column) ++ ")"
        toIMEString       =
            \ compositionData -> compositionData
                          |> Maybe.andThen (\d -> Just <| "[IME] " ++ d )
                          |> Maybe.withDefault ""
        toSelectionString =
            \ selection -> selection
                        |> Maybe.andThen (\s-> Just <|
                                              " select:(" ++ (s.begin |> Tuple.first |> toString)
                                              ++ "," ++ (s.begin |> Tuple.second |> toString) 
                                              ++ ")-(" ++ (s.end |> Tuple.first |> toString)
                                              ++ "," ++ (s.end |> Tuple.second |> toString) ++ ")"
                                         )
                        |> Maybe.withDefault ""
    in
        div [ id "modeline"
            , style [ ("background-color","black")
                    , ("color", "white")
                    ]
            ]
            [ text <| toCursorString model.editor.core.buffer.cursor
            , text <| toIMEString model.editor.core.compositionPreview
            , text <| toSelectionString model.editor.core.buffer.selection
            ]

controlPane : Model -> Html Msg
controlPane model =
    div [ id "control-pane"
        , style [("background-color", "silver")]
        ]
        [ button [ onClick MoveBackword ] [text "←"]
        , button [ onClick MovePrevios  ] [text "↑"]
        , button [ onClick MoveNext     ] [text "↓"]
        , button [ onClick MoveForward  ] [text "→"]
        , text "|"
        , button [ onClick Backspace    ] [text "BS"]
        , button [ onClick Delete       ] [text "DEL"]
        , text "|"
        , button [ onClick Copy         ] [text "Copy"]
        , button [ onClick Cut          ] [text "Cut"]
        , button [ onClick Pasete       ] [text "Paste"]
        , text "|"
        , button [ onClick Undo         ] [text "Undo"]
        , text "|"
        , input [ type_ "file", id "file_open" ][]
        ]

debugPane : Model -> Html Msg
debugPane model =
    div [ id "debug-pane"
        , class "hbox"
        , style [ ("display", "flex")
                , ("flex-direction", "row")
                , ("width" , "100%"), ("height", "100%")
                , ("flex-grow", "3")
                , ("min-height", "3em")
                , ("max-height", "8em")
                ]
        ]
        [ div [ id "debug-pane-history"
              , style [ ("min-width", "8em")
                      , ("overflow","scroll")
                      , ("flex-grow", "2")
                      ]
              ]
              ( List.map
                    (\ c ->
                         let
                             pos2str = \ row col -> "(" ++ (toString row) ++ ", " ++ (toString col) ++")" 
                             celstyle = style [("text-wrap", "none"), ("white-space","nowrap"), ("color", "gray")]
                         in
                             case c of
                                 Buffer.Cmd_Insert (row, col) str ->
                                     div [celstyle] [ "Ins" ++ (pos2str row col) ++ "{" ++ str ++ "}" |> text ]
                                 Buffer.Cmd_Backspace (row, col) str ->
                                     div [celstyle] [ "Bs_" ++ (pos2str row col) ++ "{" ++ str ++ "}" |> text ]
                                 Buffer.Cmd_Delete (row, col) str ->
                                     div [celstyle] [ "Del" ++ (pos2str row col) ++ "{" ++ str ++ "}" |> text ]
                    ) model.editor.core.buffer.history
              )
        , div [ class "vbox"
              , style [ ("flex-grow", "8")
                      , ("display", "flex"), ("flex-direction", "column")
                      ]
              ]
              [ div [ id "debug-pane-clipboard"
                    , class "hbox"
                    , style [ ("flex-grow", "2")
                            , ("width", "100%")
                            , ("min-height", "2em")
                            , ("display", "flex"), ("flex-direction", "row")
                            ]
                    ]
                    [ div [ style [ ("background-color","gray"), ("color", "white"), ("width", "10ex")] ] [text "clipboard:"]
                    , div [ style [ ("overflow","auto"), ("width", "100%") ]
                          ]
                          ( List.map
                                (λ ln-> div [ style [("border-bottom", "1px dotted gray"), ("height", "1em")] ] [ text ln ] )
                                (String.lines model.editor.core.copyStore)
                          )
                    ]
              , div [ id "debug-pane-eventlog"
                    , class "hbox"
                    , style [ ("flex-grow", "8")
                            , ("width", "100%")
                            , ("min-height", "2em")
                            , ("display", "flex"), ("flex-direction", "row")
                            ]
                    ]
                    [ div [ style [ ("background-color","gray"), ("color", "white"), ("width", "10ex")] ]
                          [ div [] [text "eventlog:"]
                          , div [ onClick (SetEventlogEnable (model.editor.event_log == Nothing))
                                , style [ ("border", "1px solid white")
                                        , ("opacity", if (model.editor.event_log == Nothing) then "0.5" else "1.0" )
                                        , ("margin", "1ex")
                                        , ("text-align", "center")
                                        ]
                                ]
                                [text <| if (model.editor.event_log == Nothing) then "OFF" else "ON"]
                          ]
                    , div [ style [ ("overflow","scroll")
                                  , ("width", "calc( 100% - 2px )")
                                  , ("border", "1px solid black")
                                  , ("flex-grow", "8")
                                  ]
                          ]
                          ( List.map (λ ln -> span [ style [("margin-right","0.2em")]] [text ln]) (Maybe.withDefault [] model.editor.event_log) )
                    ]
              ]
        ]


 
