/*
Copyright 2002-2008 Corey Trager
Distributed under the terms of the GNU General Public License
*/

using System;
using System.Web;
using System.Data;

namespace btnet
{

    public class SortableHtmlTable
    {

        ///////////////////////////////////////////////////////////////////////
        public static void create_from_dataset(
            HttpResponse r,
            DataSet ds,
            string edit_url,
            string delete_url)
        {
            create_from_dataset(r, ds, edit_url, delete_url, true);
        }


        ///////////////////////////////////////////////////////////////////////
        public static void create_from_dataset(
            HttpResponse r,
            DataSet ds,
            string edit_url,
            string delete_url,
            bool html_encode)
        {
            create_start_of_table(r);
            create_headings(r, ds, edit_url, delete_url);
            create_body(r, ds, edit_url, delete_url, html_encode);
            create_end_of_table(r);
        }

        ///////////////////////////////////////////////////////////////////////
        public static void create_start_of_table(
            HttpResponse r)
        {

            r.Write("\n<div id=wait class=please_wait>&nbsp;</div>\n");
            r.Write("<div class=click_to_sort>click on column headings to sort</div>\n");
            r.Write("<div id=myholder>\n");
            //r.Write ("<table id=mytable class=datat border=1 cellspacing=0 cellpadding=2>\n");
            r.Write("<table id=mytable border=1 class=datat>\n");

        }

        ///////////////////////////////////////////////////////////////////////
        public static void create_end_of_table(
            HttpResponse r)
        {

            // data
            r.Write("</table>\n");
            r.Write("</div>\n");
            r.Write("<div id=sortedby>&nbsp;</div>\n");

        }

        ///////////////////////////////////////////////////////////////////////
        // headings
        ///////////////////////////////////////////////////////////////////////
        public static void create_headings(
            HttpResponse r,
            DataSet ds,
            string edit_url,
            string delete_url)
        {

            r.Write("<tr>\n");

            int db_column_count = 0;

            foreach (DataColumn dc in ds.Tables[0].Columns)
            {

                if ((edit_url != "" || delete_url != "")
                && db_column_count == (ds.Tables[0].Columns.Count - 1))
                {
                    if (edit_url != "")
                    {
                        r.Write("<td class=datah valign=bottom>edit</td>");
                    }
                    if (delete_url != "")
                    {
                        r.Write("<td class=datah valign=bottom>delete</td>");
                    }

                }
                else
                {

                    // determine data type
                    string datatype = "";
                    if (Util.is_numeric_datatype(dc.DataType.ToString()))
                    {
                        datatype = "num";
                    }
                    else if (dc.DataType.ToString() == "System.DateTime")
                    {
                        datatype = "date";
                    }
                    else
                    {
                        datatype = "str";
                    }

                    r.Write("<td class=datah valign=bottom>\n");

                    if (dc.ColumnName.StartsWith("$no_sort_"))
                    {
                        r.Write(dc.ColumnName.Replace("$no_sort_", ""));
                    }
                    else
                    {
                        string sortlink = "<a href='javascript: sort_by_col($col, \"$type\")'>";
                        sortlink = sortlink.Replace("$col", Convert.ToString(db_column_count));
                        sortlink = sortlink.Replace("$type", datatype);
                        r.Write(sortlink);
                        r.Write(dc.ColumnName);
                        r.Write("</a>");
                    }

                    //r.Write ("<br>"); // for debugging
                    //r.Write (dc.DataType);

                    r.Write("</td>\n");

                }

                db_column_count++;

            }
            r.Write("</tr>\n");

        }


        ///////////////////////////////////////////////////////////////////////
        // body, data
        ///////////////////////////////////////////////////////////////////////
        public static void create_body(
            HttpResponse r,
            DataSet ds,
            string edit_url,
            string delete_url,
            bool html_encode)
        {

            foreach (DataRow dr in ds.Tables[0].Rows)
            {
                r.Write("\n<tr>");
                for (int i = 0; i < ds.Tables[0].Columns.Count; i++)
                {
                    string datatype = ds.Tables[0].Columns[i].DataType.ToString();

                    if ((edit_url != "" || delete_url != "")
                    && i == (ds.Tables[0].Columns.Count - 1))
                    {
                        if (edit_url != "")
                        {
                            r.Write("<td class=datad><a href="
                                + edit_url + dr[ds.Tables[0].Columns.Count - 1] + ">edit</a></td>");
                        }
                        if (delete_url != "")
                        {
                            r.Write("<td class=datad><a href="
                                + delete_url + dr[ds.Tables[0].Columns.Count - 1] + ">delete</a></td>");
                        }
                    }
                    else
                    {
                        if (Util.is_numeric_datatype(datatype))
                        {
                            r.Write("<td class=datad align=right>");
                        }
                        else
                        {
                            r.Write("<td class=datad>");
                        }
                        if (dr[i].ToString() == "")
                        {
                            r.Write("&nbsp;");
                        }
                        else
                        {
                            if (datatype == "System.DateTime")
                            {
                                r.Write(Util.format_db_date(dr[i]));
                            }
                            else
                            {
                                if (html_encode)
                                {
                                    r.Write(HttpUtility.HtmlEncode(dr[i].ToString()));
                                }
                                else
                                {
                                    r.Write(dr[i]);
                                }
                            }
                        }
                        r.Write("</td>");
                    }

                }
                r.Write("</tr>\n");
            }

        }
    } // end SortableHtmlTable

} // end namespace