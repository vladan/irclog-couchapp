module Models exposing (..)

import Date exposing (Date)
import Http exposing (Error)
import Json.Decode as Decode
import Date exposing (Date)


type alias IrcMessage = { timestamp: Date, sender: String, channel: String, message: String }
type alias IrcMessages = List IrcMessage
type alias ViewResult = { rows: IrcMessages, update_seq: String, total_rows: Int, offset: Int }

type alias Model = { channelName: String, messages: IrcMessages }

type Msg =
  ChannelViewResult (Result Http.Error ViewResult)
  | ChannelChanges (Result Http.Error ViewResult)
  | Increment
  | Decrement

-- Json decoder for the models
-- The Couch View result:
-- {"total_rows":717308,"offset":94922,"update_seq":"718435-g1AAAAFreJzLYWBg4MhgTmEQTM4vTc5ISXIwNDLXMwBCwxygFFMeC5BkWACk_v__vz8riYExXhmP8iQFIJlkD1QLUhr3Hp9SB5DSeKjSmF8EHXEA4oj7YJPdCSp_AFEONj3BiqDyBojy-WAvzsDn7gSQu-uhJsfb4VGayJAkDwsKhiwASS5k9A",
-- "rows":[
--  {"id":"6d29a29c16e5d50e0f9512b09392bd8f","key":["lugola",1513961232.4929347],"value":null,"doc":{"_id":"6d29a29c16e5d50e0f9512b09392bd8f","_rev":"1-26a95effe55022a5656c92b3c768b0cb","sender":"damjan","channel":"lugola","message":"и што е разлика меѓу type и type alias","timestamp":1513961232.4929347}},
--  {"id":"6d29a29c16e5d50e0f9512b09392b52a","key":["lugola",1513961220.2767942],"value":null,"doc":{"_id":"6d29a29c16e5d50e0f9512b09392b52a","_rev":"1-551157ee6d4bb25eb67eefb11ad4b7d1","sender":"damjan","channel":"lugola","message":"vnz|m: како се викаше дечкото со elm ? :)","timestamp":1513961220.2767942}},
--  {"id":"6d29a29c16e5d50e0f9512b09392b243","key":["lugola",1513961046.2759392],"value":null,"doc":{"_id":"6d29a29c16e5d50e0f9512b09392b243","_rev":"1-267b48cc1888eb0d5f54d5d5c9768676","sender":"damjan","channel":"lugola","message":"епа не ми влегло и ме нервира","timestamp":1513961046.2759392}},
--  {"id":"6d29a29c16e5d50e0f9512b09392a86c","key":["lugola",1513960810.5307088],"value":null,"doc":{"_id":"6d29a29c16e5d50e0f9512b09392a86c","_rev":"1-5ebe69edbd1061036a3a5672bfec9928","sender":"jgjorgji","channel":"lugola","message":"али мислим дека доста брзо влага у меморија поготово ако користиш само тоа и предходно/наредно","timestamp":1513960810.5307088}},
--  {"id":"6d29a29c16e5d50e0f9512b093929ed6","key":["lugola",1513960766.9897487],"value":null,"doc":{"_id":"6d29a29c16e5d50e0f9512b093929ed6","_rev":"1-c3ca8148366402bc3833041fdafb66fc","sender":"jgjorgji","channel":"lugola","message":"damjan: подеси си полесно ctrl+b или нешто такво, маус е lost cause на тмукс","timestamp":1513960766.9897487}}
-- ]}

viewResultDecoder : Decode.Decoder ViewResult
viewResultDecoder =
    Decode.map4 ViewResult
      (Decode.field "rows" rowsDecoder)
      (Decode.field "update_seq" Decode.string)
      (Decode.field "total_rows" Decode.int)
      (Decode.field "offset" Decode.int)

rowsDecoder : Decode.Decoder (List IrcMessage)
rowsDecoder =
    Decode.list (Decode.field "doc" msgDecoder)

msgDecoder : Decode.Decoder IrcMessage
msgDecoder =
    Decode.map4 IrcMessage
      (Decode.field "timestamp" dateDecoder)
      (Decode.field "sender" Decode.string)
      (Decode.field "channel" Decode.string)
      (Decode.field "message" Decode.string)

dateDecoder : Decode.Decoder Date.Date
dateDecoder =
    Decode.map (\t -> Date.fromTime (t*1000)) Decode.float
