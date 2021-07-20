/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Matthias Joachim Geisler, openwebcraft <matthiasjg@openwebcraft.com>
 */

public class Journal.LogChartView : Gtk.Box {
    private Journal.Controller _controller;

    private LiveChart.Static.StaticSerie serie;
    private LiveChart.Static.StaticChart chart;

    public LogChartView () {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 0,
            expand: false
        );
    }

    construct {
        _controller = Journal.Controller.shared_instance ();
        _controller.updated_journal_logs.connect (on_updated_journal_logs);
        _controller.load_journal_logs ();
    }

    private void on_updated_journal_logs (string log_filter, bool is_tag_filter, LogModel[] logs) {
        Regex? value_unit_regex = null;
        try {
            value_unit_regex = new Regex ("%s\\s*(\\S+)".printf (log_filter));
        } catch (Error err) {
            critical (err.message);
        }

        if (is_tag_filter && log_filter == "#Weight") {
            serie = new LiveChart.Static.StaticSerie (log_filter);
            chart = new LiveChart.Static.StaticChart ();
            chart.add_serie (serie);
            chart.config.y_axis.unit = "kg";
            var categories = new Gee.ArrayList<string> ();
            for (int i = logs.length - 1; i + 1 > 0; --i) {
                var log = logs[i];
                var relative_created_at = log.get_relative_created_at ();
                categories.add (relative_created_at);
                serie.add (relative_created_at, 5000);
            }
            chart.set_categories (categories);

            pack_start (chart, true, true, 0);

            this.expand = true;
        } else {
            if (chart != null) {
                remove (chart);
            }
            this.expand = false;
        }
        show_all ();
    }

}