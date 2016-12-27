# Copyright 2016 Yoshihiro Tanaka
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

  # http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Yoshihiro Tanaka <contact@cordea.jp>
# date  :2016-12-27

import os
import json
import httpclient, cgi
import strutils, parseopt2

const version = "0.1"

proc getApiKey(): string =
  const
    credFile = "credential.txt"
    credDir = ".trans/"
  let
    home = getEnv("HOME")
    credPath = home / credDir / credFile

  if credPath.fileExists():
    let
      cred = credPath.readFile()
    return cred.strip()
  quit 1

proc trans(key, text, frm, to: string): Response =
  var
    url = "https://translation.googleapis.com/language/translate/v2"
  url = url & "?key=$#&q=$#&target=$#&source=$#" % [ key, encodeUrl(text), encodeUrl(to), encodeUrl(frm) ]
  return newHttpClient().get url

proc getErrorText(json: JsonNode): string =
  let
    err = json["error"]
    msg = err["message"].str
    code = err["code"].getNum
  return "$#: $#" % [ $code, msg ]

proc getResult(response: Response): string =
  let
    obj = parseJson response.body
  if response.status.startsWith("200"):
    let
      translations = obj["data"]["translations"]
    return translations[0]["translatedText"].str
  else:
    return getErrorText obj

proc getHelp(): string =
  return ""

proc getVersion(): string =
  return version

when isMainModule:
  var
    text: string
    frm: string
    to: string

  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      text = key
    of cmdLongOption, cmdShortOption:
      case key
      of "f", "from":
        frm = val
      of "t", "to":
        to = val
      of "v", "version":
        echo getVersion()
      of "help":
        echo getHelp()
      else: discard
    else: discard

  if text == nil:
    quit 1
  else:
    if frm == nil:
      frm = "ja"
    if to == nil:
      to = "en"
    let
      key = getApiKey()
      resp = trans(key, text, frm, to)
      r = getResult resp
    echo r
