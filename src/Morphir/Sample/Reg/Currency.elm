{-
   Copyright 2020 Morgan Stanley

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-}


module Morphir.Sample.Reg.Currency exposing (..)

import Morphir.Sample.Reg.Country as Country exposing (Country(..))


type Currency
    = AED
    | AFN
    | ALL
    | AMD
    | ANG
    | AOA
    | ARS
    | AUD
    | AWG
    | AZN
    | BAM
    | BBD
    | BDT
    | BGN
    | BHD
    | BIF
    | BMD
    | BND
    | BOB
    | BRL
    | BSD
    | BWP
    | BYN
    | BZD
    | CAD
    | CDF
    | CHF
    | CLP
    | CNY
    | COP
    | CRC
    | CUP --,CUC
    | CVE
    | CZK
    | DJF
    | DKK
    | DOP
    | DZD
    | EGP
    | ERN
    | ETB
    | EUR
    | FJD
    | GBP
    | GEL
    | GHS
    | GIP
    | GMD
    | GNF
    | GTQ
    | GYD
    | HKD
    | HNL
    | HRK
    | HTG --,USD
    | HUF
    | IDR
    | ILS
    | INR --,BTN
    | IQD
    | IRR
    | ISK
    | JMD
    | JOD
    | JPY
    | KES
    | KGS
    | KHR
    | KMF
    | KPW
    | KRW
    | KWD
    | KYD
    | KZT
    | LAK
    | LBP
    | LKR
    | LRD
    | LSL --,ZAR
    | LYD
    | MAD
    | MDL
    | MGA
    | MKD
    | MMK
    | MNT
    | MOP
    | MRU
    | MUR
    | MVR
    | MWK
    | MXN
    | MYR
    | MZN
    | NAD --,ZAR
    | NGN
    | NIO
    | NOK
    | NPR
    | NZD
    | OMR
    | PAB --,USD
    | PEN
    | PGK
    | PHP
    | PKR
    | PLN
    | PYG
    | QAR
    | RON
    | RSD
    | RUB
    | RWF
    | SAR
    | SBD
    | SCR
    | SDG
    | SEK
    | SGD
    | SHP
    | SLL
    | SOS
    | SRD
    | SSP
    | STN
    | SVC --,USD
    | SYP
    | SZL
    | THB
    | TJS
    | TMT
    | TND
    | TOP
    | TRY
    | TTD
    | TZS
    | UAH
    | UGX
    | USD
    | UYU
    | UZS
    | VES
    | VND
    | VUV
    | WST
    | XAF
    | XCD
    | XOF
    | XPF
    | YER
    | ZAR
    | ZMW
    | ZWL


currencyCountries : List ( Currency, Country )
currencyCountries =
    [ ( AED, ARE )
    , ( AFN, AFG )
    , ( ALL, ALB )
    , ( AMD, ARM )
    , ( ANG, CUW )
    , ( ANG, SXM )
    , ( AOA, AGO )
    , ( ARS, ARG )
    , ( AUD, AUS )
    , ( AUD, CCK )
    , ( AUD, CXR )
    , ( AUD, HMD )
    , ( AUD, KIR )
    , ( AUD, NFK )
    , ( AUD, NRU )
    , ( AUD, TUV )
    , ( AWG, ABW )
    , ( AZN, AZE )
    , ( BAM, BIH )
    , ( BBD, BRB )
    , ( BDT, BGD )
    , ( BGN, BGR )
    , ( BHD, BHR )
    , ( BIF, BDI )
    , ( BMD, BMU )
    , ( BND, BRN )
    , ( BOB, BOL )
    , ( BRL, BRA )
    , ( BSD, BHS )
    , ( BWP, BWA )
    , ( BYN, BLR )
    , ( BZD, BLZ )
    , ( CAD, CAN )
    , ( CDF, COD )
    , ( CHF, CHE )
    , ( CHF, LIE )
    , ( CLP, CHL )
    , ( CNY, CHN )
    , ( COP, COL )
    , ( CRC, CRI )
    , ( CUP, CUB )
    , ( CVE, CPV )
    , ( CZK, CZE )
    , ( DJF, DJI )
    , ( DKK, DNK )
    , ( DKK, FRO )
    , ( DKK, GRL )
    , ( DOP, DOM )
    , ( DZD, DZA )
    , ( EGP, EGY )
    , ( ERN, ERI )
    , ( ETB, ETH )
    , ( EUR, ALA )
    , ( EUR, AND )
    , ( EUR, ATF )
    , ( EUR, AUT )
    , ( EUR, BEL )
    , ( EUR, BLM )
    , ( EUR, CYP )
    , ( EUR, DEU )
    , ( EUR, ESP )
    , ( EUR, EST )
    , ( EUR, FIN )
    , ( EUR, FRA )
    , ( EUR, GLP )
    , ( EUR, GRC )
    , ( EUR, GUF )
    , ( EUR, IRL )
    , ( EUR, ITA )
    , ( EUR, LTU )
    , ( EUR, LUX )
    , ( EUR, LVA )
    , ( EUR, MAF )
    , ( EUR, MCO )
    , ( EUR, MLT )
    , ( EUR, MNE )
    , ( EUR, MTQ )
    , ( EUR, MYT )
    , ( EUR, NLD )
    , ( EUR, PRT )
    , ( EUR, REU )
    , ( EUR, SMR )
    , ( EUR, SPM )
    , ( EUR, SVK )
    , ( EUR, SVN )
    , ( EUR, VAT )
    , ( FJD, FJI )
    , ( GBP, GBR )
    , ( GBP, GGY )
    , ( GBP, IMN )
    , ( GBP, JEY )
    , ( GEL, GEO )
    , ( GHS, GHA )
    , ( GIP, GIB )
    , ( GMD, GMB )
    , ( GNF, GIN )
    , ( GTQ, GTM )
    , ( GYD, GUY )
    , ( HKD, HKG )
    , ( HNL, HND )
    , ( HRK, HRV )
    , ( HTG, HTI )
    , ( HUF, HUN )
    , ( IDR, IDN )
    , ( ILS, ISR )
    , ( INR, IND )
    , ( INR, BTN )
    , ( IQD, IRQ )
    , ( IRR, IRN )
    , ( ISK, ISL )
    , ( JMD, JAM )
    , ( JOD, JOR )
    , ( JPY, JPN )
    , ( KES, KEN )
    , ( KGS, KGZ )
    , ( KHR, KHM )
    , ( KMF, COM )
    , ( KPW, PRK )
    , ( KRW, KOR )
    , ( KWD, KWT )
    , ( KYD, CYM )
    , ( KZT, KAZ )
    , ( LAK, LAO )
    , ( LBP, LBN )
    , ( LKR, LKA )
    , ( LRD, LBR )
    , ( LSL, LSO )
    , ( LYD, LBY )
    , ( MAD, ESH )
    , ( MAD, MAR )
    , ( MDL, MDA )
    , ( MGA, MDG )
    , ( MKD, Country.MKD )
    , ( MMK, MMR )
    , ( MNT, MNG )
    , ( MOP, MAC )
    , ( MRU, MRT )
    , ( MUR, MUS )
    , ( MVR, MDV )
    , ( MWK, MWI )
    , ( MXN, MEX )
    , ( MYR, MYS )
    , ( MZN, MOZ )
    , ( NAD, NAM )
    , ( NGN, NGA )
    , ( NIO, NIC )
    , ( NOK, BVT )
    , ( NOK, NOR )
    , ( NOK, SJM )
    , ( NPR, NPL )
    , ( NZD, COK )
    , ( NZD, NIU )
    , ( NZD, NZL )
    , ( NZD, PCN )
    , ( NZD, TKL )
    , ( OMR, OMN )
    , ( PAB, PAN )
    , ( PEN, PER )
    , ( PGK, PNG )
    , ( PHP, PHL )
    , ( PKR, PAK )
    , ( PLN, POL )
    , ( PYG, PRY )
    , ( QAR, QAT )
    , ( RON, ROU )
    , ( RSD, SRB )
    , ( RUB, RUS )
    , ( RWF, RWA )
    , ( SAR, SAU )
    , ( SBD, SLB )
    , ( SCR, SYC )
    , ( SDG, SDN )
    , ( SEK, SWE )
    , ( SGD, SGP )
    , ( SHP, SHN )
    , ( SLL, SLE )
    , ( SOS, SOM )
    , ( SRD, SUR )
    , ( SSP, SSD )
    , ( STN, STP )
    , ( SVC, SLV )
    , ( SYP, SYR )
    , ( SZL, SWZ )
    , ( THB, THA )
    , ( TJS, TJK )
    , ( TMT, TKM )
    , ( TND, TUN )
    , ( TOP, TON )
    , ( TRY, TUR )
    , ( TTD, TTO )
    , ( TZS, TZA )
    , ( UAH, UKR )
    , ( UGX, UGA )
    , ( USD, ASM )
    , ( USD, BES )
    , ( USD, ECU )
    , ( USD, FSM )
    , ( USD, GUM )
    , ( USD, IOT )
    , ( USD, MHL )
    , ( USD, MNP )
    , ( USD, PLW )
    , ( USD, PRI )
    , ( USD, TCA )
    , ( USD, TLS )
    , ( USD, UMI )
    , ( USD, USA )
    , ( USD, VGB )
    , ( USD, VIR )
    , ( UYU, URY )
    , ( UZS, UZB )
    , ( VES, VEN )
    , ( VND, VNM )
    , ( VUV, VUT )
    , ( WST, WSM )
    , ( XAF, CAF )
    , ( XAF, CMR )
    , ( XAF, COG )
    , ( XAF, GAB )
    , ( XAF, GNQ )
    , ( XAF, TCD )
    , ( XCD, AIA )
    , ( XCD, ATG )
    , ( XCD, DMA )
    , ( XCD, GRD )
    , ( XCD, KNA )
    , ( XCD, LCA )
    , ( XCD, MSR )
    , ( XCD, VCT )
    , ( XOF, BEN )
    , ( XOF, BFA )
    , ( XOF, CIV )
    , ( XOF, GNB )
    , ( XOF, MLI )
    , ( XOF, NER )
    , ( XOF, SEN )
    , ( XOF, TGO )
    , ( XPF, NCL )
    , ( XPF, PYF )
    , ( XPF, WLF )
    , ( YER, YEM )
    , ( ZAR, ZAF )
    , ( ZMW, ZMB )
    , ( ZWL, ZWE )
    ]


country : Currency -> Maybe Country
country currency =
    case currency of
        AUD ->
            Just AUS

        USD ->
            Just USA

        _ ->
            let
                countries : List Country
                countries =
                    currencyCountries
                        |> List.filterMap
                            (\( cy, co ) ->
                                if cy == currency then
                                    Just co

                                else
                                    Nothing
                            )
            in
            case countries of
                [ countryCode ] ->
                    Just countryCode

                _ ->
                    Nothing
