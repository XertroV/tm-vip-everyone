// See Better Room Manager for a more complete list of API calls

/** https://webservices.openplanet.dev/live/clubs/clubs-mine
    */
Json::Value@ GetMyClubs(uint length = 100, uint offset = 0) {
    return CallLiveApiPath("/api/token/club/mine?" + LengthAndOffset(length, offset));
}

// returns {accountId: string, tagClubId: int, tag: string, pinnedClub: 0 or 1}
Json::Value@ SetClubTag(uint clubId) {
    return PostLiveApiPath("/api/token/club/" + clubId + "/tag", null);
}

// returns: {"accountId":"7df60402-86e2-458b-a69b-e3261328381d","clubId":46587,"role":"Member","creationTimestamp":1683680183,"vip":true,"moderator":false,"hasFeatured":false,"pin":false,"useTag":false}
Json::Value@ SetVIP(uint clubId, const string &in wsid) {
    trace("[Club "+clubId+"] Setting member VIP: " + wsid);
    return PostLiveApiPath("/api/token/club/" + clubId + "/vip/" + wsid + "/set", null);
}

// returns: {"accountId":"7df60402-86e2-458b-a69b-e3261328381d","clubId":46587,"role":"Member","creationTimestamp":1683680183,"vip":false,"moderator":false,"hasFeatured":false,"pin":false,"useTag":false}
Json::Value@ UnsetVIP(uint clubId, const string &in wsid) {
    trace("[Club "+clubId+"] Unsetting member VIP: " + wsid);
    return PostLiveApiPath("/api/token/club/" + clubId + "/vip/" + wsid + "/unset", null);
}

// https://webservices.openplanet.dev/live/clubs/members
Json::Value@ GetClubMembers(uint clubId, uint length = 100, uint offset = 0) {
    return CallLiveApiPath("/api/token/club/" + clubId + "/member?" + LengthAndOffset(length, offset));
}
