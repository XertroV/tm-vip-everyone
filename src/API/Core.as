string[]@ GetClubTags(string[]@ wsids) {

    MwFastBuffer<wstring> _wsidList = MwFastBuffer<wstring>();
    for (uint i = 0; i < wsids.Length; i++) {
        _wsidList.Add(wstring(wsids[i]));
    }
    auto app = cast<CGameManiaPlanet>(GetApp());
    auto userId = app.MenuManager.MenuCustom_CurrentManiaApp.UserMgr.Users[0].Id;
    auto resp = app.MenuManager.MenuCustom_CurrentManiaApp.UserMgr.Tag_GetClubTagList(userId, _wsidList);
    WaitAndClearTaskLater(resp, app.MenuManager.MenuCustom_CurrentManiaApp.UserMgr);
    if (resp.HasFailed || !resp.HasSucceeded) {
        throw('getting club tags failed: ' + resp.ErrorCode + ", " + resp.ErrorType + ", " + resp.ErrorDescription);
    }
    string[] tags;
    for (uint i = 0; i < wsids.Length; i++) {
        tags.InsertLast(resp.GetClubTag(wsids[i]));
    }
    return tags;
}

string[]@ GetDisplayNames(string[]@ wsids) {
    MwFastBuffer<wstring> _wsidList = MwFastBuffer<wstring>();
    for (uint i = 0; i < wsids.Length; i++) {
        _wsidList.Add(wstring(wsids[i]));
    }
    auto app = cast<CGameManiaPlanet>(GetApp());
    auto userId = app.MenuManager.MenuCustom_CurrentManiaApp.UserMgr.Users[0].Id;
    auto resp = app.MenuManager.MenuCustom_CurrentManiaApp.UserMgr.GetDisplayName(userId, _wsidList);
    WaitAndClearTaskLater(resp, app.MenuManager.MenuCustom_CurrentManiaApp.UserMgr);
    if (resp.HasFailed || !resp.HasSucceeded) {
        throw('getting club tags failed: ' + resp.ErrorCode + ", " + resp.ErrorType + ", " + resp.ErrorDescription);
    }
    string[] names;
    for (uint i = 0; i < wsids.Length; i++) {
        names.InsertLast(resp.GetDisplayName(wsids[i]));
    }
    return names;
}


const string LocalAccountId {
    get {
        return cast<CGameManiaPlanet>(GetApp()).MenuManager.MenuCustom_CurrentManiaApp.LocalUser.WebServicesUserId;
    }
}
