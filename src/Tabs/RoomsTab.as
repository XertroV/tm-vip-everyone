
class MembersTab : Tab {
    int clubId;
    string clubName, clubTag, role;
    Json::Value@ members = Json::Array();
    bool loading = false;
    bool IsLimited = false;
    bool disableActiveToggleSafety = false;

    MembersTab(int clubId, const string &in clubName, const string &in clubTag, const string &in role) {
        string inParens = clubTag.Length > 0 ? clubTag : clubName;
        super(Icons::BuildingO + " " + inParens + "\\$z: Members", false);
        this.clubId = clubId;
        this.clubName = clubName;
        this.clubTag = clubTag;
        this.role = role;
        this.IsLimited = role == CONTENT_CREATOR;
        if (!IsLimited) disableActiveToggleSafety = true;
        startnew(CoroutineFunc(SetMembers));
        canCloseTab = true;
    }

    uint memberCount = 0;
    uint maxPage = 0;
    uint vipCount = 0;

    void SetMembers() {
        @members = Json::Array();
        nbStarted = 0;
        nbDone = 0;
        loading = true;
        try {
            auto resp = GetClubMembers(clubId);
            AddMembersFrom(resp['clubMemberList']);
            maxPage = resp['maxPage'];
            memberCount = resp['itemCount'];
            if (maxPage > 1) GetAdditionalMembers();
            loading = false;
        } catch {
            NotifyWarning('Failed to update rooms list: ' + getExceptionInfo());
        }
    }

    // todo
    void AddMembersFrom(Json::Value@ membersList) {
        if (membersList.GetType() != Json::Type::Array) throw('activity list not an array');
        for (uint i = 0; i < membersList.Length; i++) {
            auto item = membersList[i];
            members.Add(item);
            if (bool(item['vip'])) {
                vipCount++;
            }
        }
    }

    void GetAdditionalMembers() {
        for (uint page = 2; page <= maxPage; page++) {
            AddMembersFrom(GetClubMembers(clubId, 100, (page - 1) * 100)['clubMemberList']);
        }
    }

    bool enableBtn = false;
    float ctrlRhsWidth;
    vec4 ctrlBtnRect;
    float lastActiveColumnCursorX = 200;
    void DrawControlBar() {
        float width = UI::GetContentRegionMax().x;

        UI::BeginDisabled(loading);
        // ControlButton(Icons::Plus + "##room-add", CoroutineFunc(this.OnClickAddRoom));
        ControlButton(Icons::Refresh + "##room-refresh", CoroutineFunc(this.SetMembers));
        ctrlBtnRect = UI::GetItemRect();

        UI::EndDisabled();

        if (loading) {
            UI::AlignTextToFramePadding();
            UI::Text("Loading...");
            UI::SameLine();
        }
    }

    void DrawInner() override {
        UI::BeginDisabled(loading);
        DrawControlBar();
        UI::EndDisabled();

        enableBtn = UI::Checkbox("Enable set everyone VIP button", enableBtn);
        UI::Separator();

        UI::BeginDisabled(loading || !enableBtn);
        UI::Text("Members: " + members.Length);
        UI::Text("VIPs: " + vipCount);
        if (UI::Button("Set Everyone VIP")) {
            Notify("Started set everyone VIP for club: " + clubName);
            loading = true;
            m_settingVip = true;
            enableBtn = false;
            startnew(CoroutineFunc(SetAllMembersVIP));
        }
        if (UI::Button("Remove all VIP")) {
            Notify("Started remove all VIP for club: " + clubName);
            loading = true;
            m_settingVip = false;
            enableBtn = false;
            startnew(CoroutineFunc(SetAllMembersVIP));
        }
        UI::EndDisabled();

        if (loading && nbStarted > 0) {
            UI::Text("Progress: " + nbDone + " / " + nbStarted);
        }
    }

    vec2 get_ButtonIconSize() {
        float s = UI::GetFrameHeight();
        return vec2(s, s);
    }

    uint nbStarted = 0, nbDone = 0;
    bool m_settingVip = true;

    void SetAllMembersVIP() {
        bool setToVIP = m_settingVip;
        sleep(50);
        nbStarted = 0; nbDone = 0;
        for (uint i = 0; i < members.Length; i++) {
            auto member = members[i];
            bool isVip = member['vip'];
            if (isVip == setToVIP) {
                nbStarted += 1;
                nbDone += 1;
                continue;
            }
            string wsid = member['accountId'];
            startnew(setToVIP ? CoroutineFuncUserdataString(RunSetAMemberVIP) : CoroutineFuncUserdataString(RunUnsetAMemberVIP), wsid);
            member['vip'] = setToVIP;
            sleep(50);
        }
        while (nbStarted != nbDone) yield();
        loading = false;
        Notify("Finished set everyone VIP for " + clubName);
    }

    void RunSetAMemberVIP(const string &in wsid) {
        nbStarted = nbStarted + 1;
        SetVIP(clubId, wsid);
        nbDone = nbDone + 1;
        vipCount++;
    }

    void RunUnsetAMemberVIP(const string &in wsid) {
        nbStarted = nbStarted + 1;
        UnsetVIP(clubId, wsid);
        nbDone = nbDone + 1;
        vipCount--;
    }
}
