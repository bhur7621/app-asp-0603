<%@ Page language="C#"%>
<!--
Copyright 2002-2008 Corey Trager
Distributed under the terms of the GNU General Public License
-->
<!-- #include file = "inc.aspx" -->

<script language="C#" runat="server">

/*

validate integers, decimals

add settings to Web.config

adjust select statement


*/

int tsk_id;
int bugid;
String sql;

DbUtil dbutil;
Security security;

void Page_Init (object sender, EventArgs e) {ViewStateUserKey = Session.SessionID;}


///////////////////////////////////////////////////////////////////////
void Page_Load(Object sender, EventArgs e)
{

	Util.do_not_cache(Response);
	dbutil = new DbUtil();
	security = new Security();
	security.check_security(dbutil, HttpContext.Current, Security.MUST_BE_ADMIN);

	msg.InnerText = "";
	
	string string_bugid = btnet.Util.sanitize_integer(Request["bugid"]);
	bugid = Convert.ToInt32(string_bugid);

	int permission_level = Bug.get_bug_permission_level(bugid, security);

	if (permission_level != Security.PERMISSION_ALL)
	{
		Response.Write("You are not allowed to edit this item");
		Response.End();
	}		
	

	string string_tsk_id = btnet.Util.sanitize_integer(Request["id"]);
	tsk_id_static.InnerHtml = string_tsk_id;
	tsk_id = Convert.ToInt32(string_tsk_id);

	if (!IsPostBack)
	{

		titl.InnerText = btnet.Util.get_setting("AppTitle","BugTracker.NET") + " - "
			+ "edit task";

		bugid_label.InnerHtml = btnet.Util.capitalize_first_letter(btnet.Util.get_setting("SingularBugLabel","bug")) + " ID:";
		bugid_static.InnerHtml = Convert.ToString(bugid);

		load_users_dropdowns(bugid);

		if (btnet.Util.get_setting("ShowTaskAssignedTo","1") == "0")
		{
			assigned_to_tr.Visible = false;
		}
		
		if (btnet.Util.get_setting("ShowTaskPlannedStartDate","1") == "0")
		{
			planned_start_date_tr.Visible = false;
		}
		if (btnet.Util.get_setting("ShowTaskActualStartDate","1") == "0")
		{
			actual_start_date_tr.Visible = false;
		}
		
		if (btnet.Util.get_setting("ShowTaskPlannedEndDate","1") == "0")
		{
			planned_end_date_tr.Visible = false;
		}
		if (btnet.Util.get_setting("ShowTaskActualEndDate","1") == "0")
		{
			actual_end_date_tr.Visible = false;
		}
		
		if (btnet.Util.get_setting("ShowTaskPlannedDuration","1") == "0")
		{
			planned_duration_tr.Visible = false;
		}
		if (btnet.Util.get_setting("ShowTaskActualDuration","1") == "0")
		{
			actual_duration_tr.Visible = false;
		}
		

		if (btnet.Util.get_setting("ShowTaskDurationUnits","1") == "0")
		{
			duration_units_tr.Visible = false;
		}

		if (btnet.Util.get_setting("ShowTaskPercentComplete","1") == "0")
		{
			percent_complete_tr.Visible = false;
		}
		
		if (btnet.Util.get_setting("ShowTaskStatus","1") == "0")
		{
			status_tr.Visible = false;
		}		

		if (btnet.Util.get_setting("ShowTaskSortSequence","1") == "0")
		{
			sort_sequence_tr.Visible = false;
		}		


		// add or edit?
		if (tsk_id == 0)
		{

			tsk_id_tr.Visible = false;
			sub.Value = "Create";

            string default_duration_units = btnet.Util.get_setting("TaskDefaultDurationUnits","hours");
           	duration_units.Items.FindByText(default_duration_units).Selected = true;

            string default_hour = btnet.Util.get_setting("TaskDefaultHour","09");
           	planned_start_hour.Items.FindByText(default_hour).Selected = true;
           	actual_start_hour.Items.FindByText(default_hour).Selected = true;
           	planned_end_hour.Items.FindByText(default_hour).Selected = true;
           	actual_end_hour.Items.FindByText(default_hour).Selected = true;

			string default_status = btnet.Util.get_setting("TaskDefaultStatus","[no status]");
            status.Items.FindByText(default_status).Selected = true;
			
		}
		else
		{

			// Get this entry's data from the db and fill in the form

			sql = @"select * from bug_tasks where tsk_id = $tsk_id and tsk_bug = $bugid";
			sql = sql.Replace("$tsk_id", Convert.ToString(tsk_id));
			sql = sql.Replace("$bugid", Convert.ToString(bugid));
			DataRow dr = dbutil.get_datarow(sql);
           
            assigned_to.Items.FindByValue(Convert.ToString(dr["tsk_assigned_to_user"])).Selected = true;

            duration_units.Items.FindByText(Convert.ToString(dr["tsk_duration_units"])).Selected = true;

            status.Items.FindByValue(Convert.ToString(dr["tsk_status"])).Selected = true;
            
            planned_duration.Value = Convert.ToString(dr["tsk_planned_duration"]);
			actual_duration.Value = Convert.ToString(dr["tsk_actual_duration"]);
			percent_complete.Value = Convert.ToString(dr["tsk_percent_complete"]);
			sort_sequence.Value = Convert.ToString(dr["tsk_sort_sequence"]);
			desc.Value = Convert.ToString(dr["tsk_description"]);

            load_date_hour_min(
                planned_start_date,
                planned_start_hour,
                planned_start_min,
                dr["tsk_planned_start_date"]);                

            load_date_hour_min(
                actual_start_date,
                actual_start_hour,
                actual_start_min,
                dr["tsk_actual_start_date"]);

            load_date_hour_min(
                planned_end_date,
                planned_end_hour,
                planned_end_min,
                dr["tsk_planned_end_date"]);

            load_date_hour_min(
                actual_end_date,
                actual_end_hour,
                actual_end_min,
                dr["tsk_actual_end_date"]);
                                                
			sub.Value = "Update";

		}
	}
}

///////////////////////////////////////////////////////////////////////
void load_date_hour_min(
    HtmlInputText date_control,
    DropDownList hour_control, 
    DropDownList min_control, 
    object date)
{

    if (Convert.IsDBNull(date))
    {
        date_control.Value = "";
    }
    else
    {
        DateTime dt = Convert.ToDateTime(date);
        string temp_date = dt.Year.ToString("0000") + "-" + dt.Month.ToString("00") + "-" + dt.Day.ToString("00");
        date_control.Value = btnet.Util.format_db_date_and_time(Convert.ToDateTime(temp_date));
        hour_control.Items.FindByValue(dt.Hour.ToString("00")).Selected = true;
        min_control.Items.FindByValue(dt.Minute.ToString("00")).Selected = true;
    }
}

///////////////////////////////////////////////////////////////////////
void load_users_dropdowns(int bugid)
{
	// What's selected now?   Save it before we refresh the dropdown.
	string current_value = "";

	if (IsPostBack)
	{
		current_value = assigned_to.SelectedItem.Value;
	}

	sql = @"
declare @project int
select @project = bg_project from bugs where bg_id = $bg_id";

	// Load the user dropdown, which changes per project
	// Only users explicitly allowed will be listed
    if (btnet.Util.get_setting("DefaultPermissionLevel", "2") == "0")
    {
        sql += @"

/* users this project */ select us_id, case when $fullnames then us_lastname + ', ' + us_firstname else us_username end us_username
from users
inner join orgs on us_org = og_id
where us_active = 1
and og_can_be_assigned_to = 1
and ($og_other_orgs_permission_level <> 0 or $og_id = og_id)
and us_id in
    (select pu_user from project_user_xref
        where pu_project = @project
	    and pu_permission_level <> 0)
order by us_username; ";
    }
    // Only users explictly DISallowed will be omitted
    else
    {
        sql += @"
/* users this project */ select us_id, case when $fullnames then us_lastname + ', ' + us_firstname else us_username end us_username
from users
inner join orgs on us_org = og_id
where us_active = 1
and og_can_be_assigned_to = 1
and ($og_other_orgs_permission_level <> 0 or $og_id = og_id)
and us_id not in
    (select pu_user from project_user_xref
	    where pu_project = @project
		and pu_permission_level = 0)
order by us_username; ";
    }


	sql += "\nselect st_id, st_name from statuses order by st_sort_seq, st_name";

	sql = sql.Replace("$og_id",Convert.ToString(security.user.org));
	sql = sql.Replace("$og_other_orgs_permission_level", Convert.ToString(security.user.other_orgs_permission_level));
	sql = sql.Replace("$bg_id",Convert.ToString(bugid));
	
	if (Util.get_setting("UseFullNames","0") == "0")
	{
		// false condition
		sql = sql.Replace("$fullnames","0 = 1");
	}
	else
	{
		// true condition
		sql = sql.Replace("$fullnames","1 = 1");
	}

    
	assigned_to.DataSource = new DataView((DataTable)dbutil.get_dataset(sql).Tables[0]);	
	assigned_to.DataTextField = "us_username";
	assigned_to.DataValueField = "us_id";
	assigned_to.DataBind();
	assigned_to.Items.Insert(0, new ListItem("[not assigned]", "0"));

	status.DataSource = new DataView((DataTable)dbutil.get_dataset(sql).Tables[1]);	
	status.DataTextField = "st_name";
	status.DataValueField = "st_id";
	status.DataBind();
	status.Items.Insert(0, new ListItem("[no status]", "0"));


}

///////////////////////////////////////////////////////////////////////
Boolean validate()
{
	Boolean good = true;
	return good;
}


///////////////////////////////////////////////////////////////////////
string format_date_hour_min(string date, string hour, string min)
{
	if (!string.IsNullOrEmpty(date))
	{
		return date
		+ " "
		+ hour
		+ ":"
		+ min
		+ ":00";
	}
	else
	{
		return "";
	}
}

///////////////////////////////////////////////////////////////////////
string format_number_for_db(string s)
{
	if (s == "")
		return "null";
	else
		return s;
}

///////////////////////////////////////////////////////////////////////
void on_update (Object sender, EventArgs e)
{

	Boolean good = validate();

	if (good)
	{
		if (tsk_id == 0)  // insert new
		{
			sql = @"
insert into bug_tasks (
tsk_bug,
tsk_created_user,
tsk_created_date,
tsk_last_updated_user,
tsk_last_updated_date,
tsk_assigned_to_user,
tsk_planned_start_date,
tsk_actual_start_date,
tsk_planned_end_date,
tsk_actual_end_date,
tsk_planned_duration,
tsk_actual_duration,
tsk_duration_units,
tsk_percent_complete,
tsk_status,
tsk_sort_sequence,
tsk_description
)
values (
$tsk_bug,
$tsk_created_user,
getdate(),
$tsk_last_updated_user,
getdate(),
$tsk_assigned_to_user,
'$tsk_planned_start_date',
'$tsk_actual_start_date',
'$tsk_planned_end_date',
'$tsk_actual_end_date',
$tsk_planned_duration,
$tsk_actual_duration,
N'$tsk_duration_units',
$tsk_percent_complete,
$tsk_status,
$tsk_sort_sequence,
N'$tsk_description'
)";

			sql = sql.Replace("$tsk_bug", Convert.ToString(bugid));
			sql = sql.Replace("$tsk_created_user", Convert.ToString(security.user.usid));
		

		}
		else // edit existing
		{

			sql = @"
update bug_tasks set
tsk_last_updated_user = $tsk_last_updated_user,
tsk_last_updated_date = getdate(),
tsk_assigned_to_user = $tsk_assigned_to_user,
tsk_planned_start_date = '$tsk_planned_start_date',
tsk_actual_start_date = '$tsk_actual_start_date',
tsk_planned_end_date = '$tsk_planned_end_date',
tsk_actual_end_date = '$tsk_actual_end_date',
tsk_planned_duration = $tsk_planned_duration,
tsk_actual_duration = $tsk_actual_duration,
tsk_duration_units = N'$tsk_duration_units',
tsk_percent_complete = $tsk_percent_complete,
tsk_status = $tsk_status,
tsk_sort_sequence = $tsk_sort_sequence,
tsk_description = N'$tsk_description'
where tsk_id = $tsk_id";


			sql = sql.Replace("$tsk_id", Convert.ToString(tsk_id));

		}

		sql = sql.Replace("$tsk_last_updated_user", Convert.ToString(security.user.usid));
		
		sql = sql.Replace("$tsk_planned_start_date", format_date_hour_min(
			planned_start_date.Value,
			planned_start_hour.SelectedItem.Value,
			planned_start_min.SelectedItem.Value));

		sql = sql.Replace("$tsk_actual_start_date", format_date_hour_min(
			actual_start_date.Value,
			actual_start_hour.SelectedItem.Value,
			actual_start_min.SelectedItem.Value));

		sql = sql.Replace("$tsk_planned_end_date", format_date_hour_min(
			planned_end_date.Value,
			planned_end_hour.SelectedItem.Value,
			planned_end_min.SelectedItem.Value));

		sql = sql.Replace("$tsk_actual_end_date", format_date_hour_min(
			actual_end_date.Value,
			actual_end_hour.SelectedItem.Value,
			actual_end_min.SelectedItem.Value));
			
		sql = sql.Replace("$tsk_planned_duration", format_number_for_db(planned_duration.Value));
		sql = sql.Replace("$tsk_actual_duration", format_number_for_db(actual_duration.Value));
		sql = sql.Replace("$tsk_percent_complete", format_number_for_db(percent_complete.Value));
		sql = sql.Replace("$tsk_status", status.SelectedItem.Value);
		sql = sql.Replace("$tsk_sort_sequence", format_number_for_db(sort_sequence.Value));
		sql = sql.Replace("$tsk_assigned_to_user", assigned_to.SelectedItem.Value);
		sql = sql.Replace("$tsk_description", desc.Value.Replace("'","''"));
		sql = sql.Replace("$tsk_duration_units", duration_units.SelectedItem.Value.Replace("'","''"));

		dbutil.execute_nonquery(sql);
		Response.Redirect ("tasks.aspx?bugid=" + Convert.ToString(bugid));


	}
	else
	{
		if (tsk_id == 0)  // insert new
		{
			msg.InnerText = "Task was not created.";
		}
		else // edit existing
		{
			msg.InnerText = "Task was not updated.";
		}

	}

}

</script>

<html>
<head>
<title id="titl" runat="server">btnet edit task</title>

<link rel="StyleSheet" href="btnet.css" type="text/css">
<link rel="StyleSheet" href="jquery/ui.datepicker.css" type="text/css">

<script type="text/javascript" language="JavaScript" src="jquery/jquery-1.2.6.min.js"></script>
<script type="text/javascript" language="JavaScript" src="jquery/jquery-ui-1.6rc2.min.js"></script>
<script type="text/javascript" language="JavaScript" src="datejs/date.js"></script>

<script>
$(document).ready(do_doc_ready);

function do_doc_ready()
{
	date_format = '<% Response.Write(btnet.Util.get_setting("DatepickerDateFormat","yy-mm-dd")); %>'
	$(".date").datepicker({dateFormat: date_format, duration: 'fast'})
}

function show_calendar(el)
{
	$("#" + el).datepicker("show")
}


</script>

</head>
<body>

<div class=align><table border=0><tr><td>
<a href=tasks.aspx?bugid=<% Response.Write(Convert.ToString(bugid)); %>>back to tasks</a>
<p>
<form class=frm runat="server">
	<table border=0>

	<tr runat="server" id="bugid_tr">
	<td class="lbl" id="bugid_label"></td>
	<td class="lbl" id="bugid_static"></td>
	</tr>

	<tr runat="server" id="tsk_id_tr">
	<td class="lbl" id="tsk_id_label">Task ID:</td>
	<td class="lbl" id="tsk_id_static"></td>
	</tr>

	<tr runat="server" id="desc_tr">
	<td class="lbl" id="desc_label">Description:</td>
	<td><input runat="server" type="text" class="txt" id="desc" maxlength=200 size=100></td>
	</tr>

	<tr runat="server" id="assigned_to_tr">
	<td class="	lbl" id="assigned_to_label">Assigned to:</td>
	<td><asp:DropDownList id="assigned_to" runat="server"></asp:DropDownList></td>
	</tr>

	<tr runat="server" id="planned_start_date_tr">
	<td class="lbl" id="planned_start_date_lbl">Planned start date:</td>
	<td><input runat="server" type=text class="txt date" id="planned_start_date" maxlength=10 size=10>
		<a style="font-size: 8pt;"
		href="javascript:show_calendar('planned_start_date')">
		[?]
		</a>
	<span id="planned_start_hour_label">&nbsp;hour:</span>
	<asp:DropDownList id="planned_start_hour" runat="server">
		<asp:ListItem Text="00" Value="00" Selected="False" />
		<asp:ListItem Text="01" Value="01" Selected="False" />
		<asp:ListItem Text="02" Value="02" Selected="False" />
		<asp:ListItem Text="03" Value="03" Selected="False" />
		<asp:ListItem Text="04" Value="04" Selected="False" />
		<asp:ListItem Text="05" Value="05" Selected="False" />
		<asp:ListItem Text="06" Value="06" Selected="False" />
		<asp:ListItem Text="07" Value="07" Selected="False" />
		<asp:ListItem Text="08" Value="08" Selected="False" />
		<asp:ListItem Text="09" Value="09" Selected="False" />
		<asp:ListItem Text="10" Value="10" Selected="False" />
		<asp:ListItem Text="11" Value="11" Selected="False" />
		<asp:ListItem Text="12" Value="12" Selected="False" />
		<asp:ListItem Text="13" Value="13" Selected="False" />
		<asp:ListItem Text="14" Value="14" Selected="False" />
		<asp:ListItem Text="15" Value="15" Selected="False" />
		<asp:ListItem Text="16" Value="16" Selected="False" />
		<asp:ListItem Text="27" Value="17" Selected="False" />
		<asp:ListItem Text="18" Value="18" Selected="False" />
		<asp:ListItem Text="19" Value="19" Selected="False" />
		<asp:ListItem Text="20" Value="20" Selected="False" />
		<asp:ListItem Text="21" Value="21" Selected="False" />
		<asp:ListItem Text="22" Value="22" Selected="False" />
		<asp:ListItem Text="23" Value="23" Selected="False" />
	</asp:DropDownList>
	<span id="planned_start_min_label">&nbsp;min:</span>
	<asp:DropDownList id="planned_start_min" runat="server">
		<asp:ListItem Text="00" Value="00" Selected="False" />
		<asp:ListItem Text="15" Value="15" Selected="False" />
		<asp:ListItem Text="30" Value="30" Selected="False" />
		<asp:ListItem Text="45" Value="45" Selected="False" />
	</asp:DropDownList>
	</td>
	</tr>


	<tr runat="server" id="actual_start_date_tr">
	<td class="lbl" id="actual_start_date_lbl">Actual start date:</td>
	<td><input runat="server" type=text class="txt date" id="actual_start_date" maxlength=10 size=10>
		<a style="font-size: 8pt;"
		href="javascript:show_calendar('actual_start_date')">
		[?]
		</a>
	<span id="actual_start_hour_label">&nbsp;hour:</span>
	<asp:DropDownList id="actual_start_hour" runat="server">
		<asp:ListItem Text="00" Value="00" Selected="False" />
		<asp:ListItem Text="01" Value="01" Selected="False" />
		<asp:ListItem Text="02" Value="02" Selected="False" />
		<asp:ListItem Text="03" Value="03" Selected="False" />
		<asp:ListItem Text="04" Value="04" Selected="False" />
		<asp:ListItem Text="05" Value="05" Selected="False" />
		<asp:ListItem Text="06" Value="06" Selected="False" />
		<asp:ListItem Text="07" Value="07" Selected="False" />
		<asp:ListItem Text="08" Value="08" Selected="False" />
		<asp:ListItem Text="09" Value="09" Selected="False" />
		<asp:ListItem Text="10" Value="10" Selected="False" />
		<asp:ListItem Text="11" Value="11" Selected="False" />
		<asp:ListItem Text="12" Value="12" Selected="False" />
		<asp:ListItem Text="13" Value="13" Selected="False" />
		<asp:ListItem Text="14" Value="14" Selected="False" />
		<asp:ListItem Text="15" Value="15" Selected="False" />
		<asp:ListItem Text="16" Value="16" Selected="False" />
		<asp:ListItem Text="27" Value="17" Selected="False" />
		<asp:ListItem Text="18" Value="18" Selected="False" />
		<asp:ListItem Text="19" Value="19" Selected="False" />
		<asp:ListItem Text="20" Value="20" Selected="False" />
		<asp:ListItem Text="21" Value="21" Selected="False" />
		<asp:ListItem Text="22" Value="22" Selected="False" />
		<asp:ListItem Text="23" Value="23" Selected="False" />
	</asp:DropDownList>
	<span id="actual_start_min_label">&nbsp;min:</span>
	<asp:DropDownList id="actual_start_min" runat="server">
		<asp:ListItem Text="00" Value="00" Selected="False" />
		<asp:ListItem Text="15" Value="15" Selected="False" />
		<asp:ListItem Text="30" Value="30" Selected="False" />
		<asp:ListItem Text="45" Value="45" Selected="False" />
	</asp:DropDownList>
	</td>
	</tr>

	<tr runat="server" id="planned_end_date_tr">
	<td class="lbl" id="planned_end_date_lbl">Planned end date:</td>
	<td><input runat="server" type=text class="txt date" id="planned_end_date" maxlength=10 size=10>
		<a style="font-size: 8pt;"
		href="javascript:show_calendar('planned_end_date')">
		[?]
		</a>
	<span id="planned_end_hour_label">&nbsp;hour:</span>
	<asp:DropDownList id="planned_end_hour" runat="server">
		<asp:ListItem Text="00" Value="00" Selected="False" />
		<asp:ListItem Text="01" Value="01" Selected="False" />
		<asp:ListItem Text="02" Value="02" Selected="False" />
		<asp:ListItem Text="03" Value="03" Selected="False" />
		<asp:ListItem Text="04" Value="04" Selected="False" />
		<asp:ListItem Text="05" Value="05" Selected="False" />
		<asp:ListItem Text="06" Value="06" Selected="False" />
		<asp:ListItem Text="07" Value="07" Selected="False" />
		<asp:ListItem Text="08" Value="08" Selected="False" />
		<asp:ListItem Text="09" Value="09" Selected="False" />
		<asp:ListItem Text="10" Value="10" Selected="False" />
		<asp:ListItem Text="11" Value="11" Selected="False" />
		<asp:ListItem Text="12" Value="12" Selected="False" />
		<asp:ListItem Text="13" Value="13" Selected="False" />
		<asp:ListItem Text="14" Value="14" Selected="False" />
		<asp:ListItem Text="15" Value="15" Selected="False" />
		<asp:ListItem Text="16" Value="16" Selected="False" />
		<asp:ListItem Text="27" Value="17" Selected="False" />
		<asp:ListItem Text="18" Value="18" Selected="False" />
		<asp:ListItem Text="19" Value="19" Selected="False" />
		<asp:ListItem Text="20" Value="20" Selected="False" />
		<asp:ListItem Text="21" Value="21" Selected="False" />
		<asp:ListItem Text="22" Value="22" Selected="False" />
		<asp:ListItem Text="23" Value="23" Selected="False" />

	</asp:DropDownList>
	<span id="planned_end_min_label">&nbsp;min:</span>
	<asp:DropDownList id="planned_end_min" runat="server">
		<asp:ListItem Text="00" Value="00" Selected="False" />
		<asp:ListItem Text="15" Value="15" Selected="False" />
		<asp:ListItem Text="30" Value="30" Selected="False" />
		<asp:ListItem Text="45" Value="45" Selected="False" />
	</asp:DropDownList>
	</td>
	</tr>

	<tr runat="server" id="actual_end_date_tr">
	<td class="lbl" id="actual_end_date_lbl">Actual end date:</td>
	<td><input runat="server" type=text class="txt date" id="actual_end_date" maxlength=10 size=10>
		<a style="font-size: 8pt;"
		href="javascript:show_calendar('actual_end_date')">
		[?]
		</a>
	<span id="actual_end_hour_label">&nbsp;hour:</span>
	<asp:DropDownList id="actual_end_hour" runat="server">
		<asp:ListItem Text="00" Value="00" Selected="False" />
		<asp:ListItem Text="01" Value="01" Selected="False" />
		<asp:ListItem Text="02" Value="02" Selected="False" />
		<asp:ListItem Text="03" Value="03" Selected="False" />
		<asp:ListItem Text="04" Value="04" Selected="False" />
		<asp:ListItem Text="05" Value="05" Selected="False" />
		<asp:ListItem Text="06" Value="06" Selected="False" />
		<asp:ListItem Text="07" Value="07" Selected="False" />
		<asp:ListItem Text="08" Value="08" Selected="False" />
		<asp:ListItem Text="09" Value="09" Selected="False" />
		<asp:ListItem Text="10" Value="10" Selected="False" />
		<asp:ListItem Text="11" Value="11" Selected="False" />
		<asp:ListItem Text="12" Value="12" Selected="False" />
		<asp:ListItem Text="13" Value="13" Selected="False" />
		<asp:ListItem Text="14" Value="14" Selected="False" />
		<asp:ListItem Text="15" Value="15" Selected="False" />
		<asp:ListItem Text="16" Value="16" Selected="False" />
		<asp:ListItem Text="27" Value="17" Selected="False" />
		<asp:ListItem Text="18" Value="18" Selected="False" />
		<asp:ListItem Text="19" Value="19" Selected="False" />
		<asp:ListItem Text="20" Value="20" Selected="False" />
		<asp:ListItem Text="21" Value="21" Selected="False" />
		<asp:ListItem Text="22" Value="22" Selected="False" />
		<asp:ListItem Text="23" Value="23" Selected="False" />
	</asp:DropDownList>
	<span id="actual_end_min_label">&nbsp;min:</span>
	<asp:DropDownList id="actual_end_min" runat="server">
		<asp:ListItem Text="00" Value="00" Selected="False" />
		<asp:ListItem Text="15" Value="15" Selected="False" />
		<asp:ListItem Text="30" Value="30" Selected="False" />
		<asp:ListItem Text="45" Value="45" Selected="False" />
	</asp:DropDownList>
	</td>
	</tr>

	<tr runat="server" id="planned_duration_tr">
	<td class="lbl" id="planned_duration_lbl">Planned duration:</td>
	<td><input runat="server" type=text class="txt" id="planned_duration" maxlength=7 size=7></td>
	</tr>

	<tr runat="server" id="actual_duration_tr">
	<td class="lbl" id="actual_duration_lbl">Actual duration:</td>
	<td><input runat="server" type=text class="txt" id="actual_duration" maxlength=7 size=7></td>
	</tr>

	<tr runat="server" id="duration_units_tr">
	<td class="lbl" id="duration_units_lbl">Duration units:</td>
	<td>
	<asp:DropDownList id="duration_units" runat="server">
		<asp:ListItem Text="minutes" Value="minutes" Selected="False" />
		<asp:ListItem Text="hours" Value="hours" Selected="True" />
		<asp:ListItem Text="days" Value="days" Selected="False" />
	</asp:DropDownList>		
	</td>
	</tr>

	<tr runat="server" id="percent_complete_tr">
	<td class="lbl" id="percent_complete_lbl">Percent complete:</td>
	<td><input runat="server" type=text class="txt" id="percent_complete" maxlength=6 size=6></td>
	</tr>

	<tr runat="server" id="status_tr">
	<td class="lbl" id="status_lbl">Status:</td>
	<td><asp:DropDownList id="status" runat="server"></asp:DropDownList></td>
	</tr>


	<tr runat="server" id="sort_sequence_tr">
	<td class="lbl" id="sort_sequence_lbl">Sort Sequence:</td>
	<td><input runat="server" type=text class="txt" id="sort_sequence" maxlength=3 size=3></td>
	</tr>

	<tr>
	<td colspan=3 align=left>
	<span runat="server" class=err id="msg">&nbsp;</span>
	</td>
	</tr>

	<tr>
	<td colspan=3 align=center>
	<input runat="server" class=btn type=submit id="sub" value="Create or Edit" OnServerClick="on_update">
	</tr>
	
	</table>
</form>
</td></tr></table></div>
</html>

