-- Inofficial Ripple Extension for MoneyMoney
-- Fetches Ripple quantity for addresses via Ripple API
-- Fetches Ripple price in EUR via coinmarketcap API
-- Returns cryptoassets as securities
--
-- Username: Ripple Adresses comma seperated
-- Password: [Whatever]

-- MIT License

-- Copyright (c) 2017 heseifert

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.



WebBanking{
  version = 0.1,
  description = "Include your Ripple as cryptoportfolio in MoneyMoney by providing Ripple addresses as username (comma seperated) and a random Password",
  services= { "Ripple" }
}

local stellarAddress
local connection = Connection()
local currency = "EUR" -- fixme: make dynamik if MM enables input field

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Ripple"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  rippleAddress = username:gsub("%s+", "")
end

function ListAccounts (knownAccounts)
  local account = {
    name = "Ripple",
    accountNumber = "Crypto Asset Ripple",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}
  prices = requestRipplePrice()

  for address in string.gmatch(rippleAddress, '([^,]+)') do
    rippleQuantity = requestRippleQuantityForRippleAddress(address)

    s[#s+1] = {
      name = address,
      currency = nil,
      market = "cryptocompare",
      quantity = rippleQuantity,
      price = prices,
    }
  end

  return {securities = s}
end

function EndSession ()
end


-- Querry Functions
function requestRipplePrice()
  response = connection:request("GET", cryptocompareRequestUrl(), {})
  json = JSON(response)

  return json:dictionary()[1]["price_eur"]
end

function requestRippleQuantityForRippleAddress(rippleAddress)
  response = connection:request("GET", rippleRequestUrl(rippleAddress), {})
  json = JSON(response)
  
  return json:dictionary()["balances"][1]["value"]
end

-- Helper Functions

function cryptocompareRequestUrl()
  return "https://api.coinmarketcap.com/v1/ticker/Ripple/?convert=EUR"
end

function rippleRequestUrl(dashAddress)
  return "https://data.ripple.com/v2/accounts/" .. rippleAddress .. "/balances"
end