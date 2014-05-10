 {-# LANGUAGE OverloadedStrings #-}

import Control.Monad (forM_)
import Text.Blaze.Html5
import Text.Blaze.Html5.Attributes
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A
import qualified Text.Blaze.Html.Renderer.String as S

home =
  docTypeHtml $ do
    H.head $ do
      H.title "HomePage"
    body $ do
      p "Hello world"

main = do
  putStrLn "Writing index.html.."
  writeFile "index.html" (S.renderHtml home)

