<%@ Page Language="C#" %>

<!DOCTYPE html>

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        //check if the user is a cms user
        if (IsCMSUser())
        {
            //Check for postback since we don't need to reload the form list.
            if (!IsPostBack)
            {
                purgedate.Value = DateTime.Today.AddMonths(-1).ToShortDateString();
                Ektron.Cms.Framework.Content.FormManager fManager = new Ektron.Cms.Framework.Content.FormManager();
                Ektron.Cms.Common.FormCriteria criteria = new Ektron.Cms.Common.FormCriteria();
                criteria.AddFilter(Ektron.Cms.Common.FormProperty.Id, Ektron.Cms.Common.CriteriaFilterOperator.GreaterThan, 0);
                criteria.PagingInfo = new Ektron.Cms.PagingInfo(100000);
                var formList = fManager.GetList(criteria);
                if (formList.Count > 0)
                {
                    //loop through all forms and add to a list.
                    formIdList.Items.Add(new ListItem("Please select a form from the list", "0"));
                    foreach (var item in formList)
                    {
                        formIdList.Items.Add(new ListItem(item.Title, item.Id.ToString()));
                    }
                }
            }
        }
    }

    /// <summary>
    /// check if the user is a cms user.
    /// </summary>
    /// <returns></returns>
    private bool IsCMSUser()
    {
        return Ektron.Cms.ObjectFactory.GetUser().IsCmsLoggedIn;
    }
    
    /// <summary>
    /// Handle the delete event 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void delete_Click(object sender, EventArgs e)
    {
        if (IsCMSUser())
        {
            //string builder for output messaging
            StringBuilder sb = new StringBuilder();
            try
            {
                //parse the form id
                long formID = long.Parse(formIdList.SelectedValue);
                //parse the purge date
                DateTime purgeDate = DateTime.Parse(purgedate.Value);
                if (formID > 0 && purgeDate > DateTime.Now.AddYears(-20))
                {
                    //get a list of items that fall in that range
                    Ektron.Cms.Framework.Content.FormManager fManager = new Ektron.Cms.Framework.Content.FormManager();
                    Ektron.Cms.Common.FormSubmittedCriteria criteria = new Ektron.Cms.Common.FormSubmittedCriteria();
                    criteria.AddFilter(Ektron.Cms.Common.FormSubmittedProperty.FormId, Ektron.Cms.Common.CriteriaFilterOperator.EqualTo, formID);
                    criteria.AddFilter(Ektron.Cms.Common.FormSubmittedProperty.DateSubmitted, Ektron.Cms.Common.CriteriaFilterOperator.GreaterThanOrEqualTo, purgeDate);
                    criteria.PagingInfo = new Ektron.Cms.PagingInfo(1000000);
                    var data = fManager.GetSubmittedFormList(criteria);
                    Ektron.Cms.API.Content.Content capi = new Ektron.Cms.API.Content.Content();
                    Ektron.Cms.Modules.EkModule module = capi.EkModuleRef;
                    sb.Append("<div class='alert alert-info'>Total Items: " + data.Count + "</div>");
                    if (data.Count > 0)
                    {
                        //loop through items to purge.
                        foreach (var item in data)
                        {
                            try
                            {
                                sb.Append("<div class='alert alert-info'>Deleting item: " + item.Id + "</div>");
                                var success = module.PurgeFormData(formID.ToString(), item.Id.ToString());
                            }
                            catch { sb.Append("<div class='alert alert-danger'>Error Deleting item: " + item.Id + "</div>"); }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
            }
            output.Text = sb.ToString();
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Purge Form Data</title>
    <script src="https://code.jquery.com/jquery-3.0.0.min.js" integrity="sha256-JmvOoLtYsmqlsWxa7mDSLMwa6dZ9rrIdtrrVYRnDRH0="
        crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/ui/1.11.4/jquery-ui.min.js" integrity="sha256-xNjb53/rY+WmG+4L6tTl9m6PpqknWZvRt0rO1SRnJzw="
        crossorigin="anonymous"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"
        integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS"
        crossorigin="anonymous"></script>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.11.3/themes/smoothness/jquery-ui.css" />
    <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"
        rel="stylesheet" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7"
        crossorigin="anonymous">
    <script type="text/javascript">
        $(document).ready(function () {
            $(".datecontrol").datepicker({
                changeMonth: true,
                changeYear: true
            });
        })
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <h3>Purge Form Data</h3>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    Form ID:
                    <asp:DropDownList ID="formIdList" runat="server"></asp:DropDownList>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    Date to start the purge:
                    <input type="datetime" runat="server" id="purgedate" class="datecontrol form-control" />
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <asp:Button ID="delete" runat="server" Text="Purge Data" OnClick="delete_Click" CssClass="btn btn-primary" />
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <asp:Label ID="output" runat="server"></asp:Label>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
