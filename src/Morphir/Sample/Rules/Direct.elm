module Morphir.Sample.Rules.Direct exposing (..)


decisionTree : Facts -> Decision
decisionTree f =
    case f.flooredAtZero of
        Just True ->
            Yes

        Just False ->
            No

        Nothing ->
            case f.documentType of
                DRV ->
                    Yes

                French ->
                    No

                MSFTA ->
                    No

                ISDA ->
                    case f.negativeInterestProtocol of
                        Applicable ->
                            No

                        NotApplicable ->
                            case f.governingLaw of
                                England ->
                                    Yes

                                _ ->
                                    No


decisionTable : Facts -> Decision
decisionTable f =
    case    Match   f.flooredAtZero     f.documentType  f.negativeInterestProtocol  f.governingLaw    of
            ----------------------------------------------------------------------------------------------
            Match   (Just True)         _               _                           _               -> Yes
            Match   (Just False)        _               _                           _               -> No
            Match   Nothing             DRV             _                           _               -> Yes
            Match   Nothing             French          _                           _               -> No
            Match   Nothing             MSFTA           _                           _               -> No
            Match   Nothing             ISDA            Applicable                  _               -> No
            Match   Nothing             ISDA            NotApplicable               England         -> Yes
            Match   Nothing             ISDA            NotApplicable               _               -> No


type Match 
    = Match (Maybe Bool) DocumentType NegativeInterestProtocol GoverningLaw


type Decision
    = Yes
    | No


type alias Facts =
    { flooredAtZero : Maybe Bool
    , documentType : DocumentType
    , negativeInterestProtocol : NegativeInterestProtocol
    , governingLaw : GoverningLaw
    }


type DocumentType
    = DRV
    | French
    | MSFTA
    | ISDA


type NegativeInterestProtocol
    = Applicable
    | NotApplicable


type GoverningLaw
    = England
    | Other    