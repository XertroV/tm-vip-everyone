const string CONTENT_CREATOR = "Content_Creator";

class ClubsTab : Tab {
    Json::Value@ myClubs = Json::Array();
    bool loading = false;

    ClubsTab() {
        super(Icons::Users + " Clubs", false);
        startnew(CoroutineFunc(SetClubs));
    }

    uint clubCount = 0;
    uint maxPage = 0;

    void SetClubs() {
        @myClubs = Json::Array();
        loading = true;
        try {
            auto resp = GetMyClubs();
            trace('response: ' + Json::Write(resp));
            @myClubs = resp['clubList'];
            FixClubNamesTags();
            maxPage = resp['maxPage'];
            clubCount = resp['clubCount'];
            if (maxPage > 1) GetAdditionalClubs();
            FixClubNamesTags(100);
            loading = false;
        } catch {
            NotifyWarning('Failed to update clubs list: ' + getExceptionInfo());
        }
    }

    void FixClubNamesTags(uint startIx = 0) {
        for (uint i = startIx; i < myClubs.Length; i++) {
            auto club = myClubs[i];
            // print(ColoredString(club['name']));
            club['name'] = ColoredString(club['name']);
            club['tag'] = ColoredString(club['tag']);
            // print(club['name']);
        }
    }

    void GetAdditionalClubs() {
        for (uint page = 2; page <= maxPage; page++) {
            auto resp = GetMyClubs(100, (page - 1) * 100)['clubList'];
            for (uint i = 0; i < resp.Length; i++) {
                myClubs.Add(resp[i]);
            }
        }
    }

    void DrawInner() override {
        DrawControlBar();
        UI::Separator();
        DrawClubsTable();
    }

    vec2 get_ButtonIconSize() {
        float s = UI::GetFrameHeight();
        return vec2(s, s);
    }

    float ctrlRhsWidth;
    vec4 ctrlBtnRect;

    void DrawControlBar() {
        float width = UI::GetContentRegionMax().x;

        UI::BeginDisabled(loading);
        ControlButton(Icons::Refresh + "##clubs refresh", CoroutineFunc(this.SetClubs));
        UI::EndDisabled();
        ctrlBtnRect = UI::GetItemRect();

        if (loading) {
            UI::AlignTextToFramePadding();
            UI::Text("Loading...");
        } else {
            UI::Dummy(vec2());
        }
    }

    void DrawClubsTable() {
        uint nCols = 5;
        if (UI::BeginTable("clubs table", nCols, UI::TableFlags::SizingStretchProp)) {
            UI::TableSetupColumn("ID");
            UI::TableSetupColumn("Name");
            UI::TableSetupColumn("Tag");
            UI::TableSetupColumn("Role");
            UI::TableSetupColumn("##clubs col btns", UI::TableColumnFlags::WidthFixed);
            UI::TableHeadersRow();

            UI::ListClipper mapClipper(myClubs.Length);
            while (mapClipper.Step()) {
                for (int i = mapClipper.DisplayStart; i < mapClipper.DisplayEnd; i++) {
                    DrawClubsTableRow(myClubs[i]);
                }
            }

            UI::EndTable();
        }
    }

    void DrawClubsTableRow(Json::Value@ club) {
        int clubId = int(club['id']);
        string club_id = tostring(clubId);

        UI::TableNextRow();
        UI::TableNextColumn();
        UI::AlignTextToFramePadding();
        UI::Text(club_id);

        UI::TableNextColumn();
        UI::Text(club['name']);

        UI::TableNextColumn();
        UI::Text(club['tag']);

        UI::TableNextColumn();
        string role = string(club['role']);
        UI::Text(role);

        UI::TableNextColumn();
        if (role == "Creator" || role == "Admin" || role == CONTENT_CREATOR) {
            UI::BeginDisabled(RoomsTabExists(clubId));
            if (UI::Button("Members##"+club_id))
                OnClickRoomsForClub(clubId, club['name'], club['tag'], role);
            UI::EndDisabled();
        }
    }

    void OnClickRoomsForClub(int clubId, const string &in clubName, const string &in clubTag, const string &in role) {
        auto room = MembersTab(clubId, clubName, clubTag, role);
        mainTabs.InsertLast(room);
    }

    bool RoomsTabExists(int clubId) {
        for (uint i = 0; i < mainTabs.Length; i++) {
            auto rsTab = cast<MembersTab>(mainTabs[i]);
            if (rsTab !is null && rsTab.clubId == clubId) return true;
        }
        return false;
    }
}
