import { Component, OnInit, Input } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { MessageService, ResponseService, AuthService } from '@app/core/services';
import { BaseWidgetComponent } from '@app/shared/base/base-widget.component';
import { GlobalFilterService } from '@app/core/services/global-filter.service';
import { widgetConfig } from '@app/config/constants';

@Component({
  selector: '[sa-activity-counts-by-data-type]',
  templateUrl: './activity-counts-by-data-type.component.html',
})
export class ActivityCountsByDataTypeWidgetComponent extends BaseWidgetComponent implements OnInit {
  
  constructor(
    public router: Router,
    public authService: AuthService,
    public globalFilterService: GlobalFilterService
  ) {
    super(authService, globalFilterService);
  }

  ngOnInit() {
    this.widgetType = 'CHART';
    this.chartData = {
      chartType: 'ColumnChart',
      dataTable: [],
      options: {
        legend: { position: 'none', alignment: 'center'  },
        height: widgetConfig.height.chart,
        hAxis: {
          slantedText:true
        },
        vAxis: {
          minValue: 0
        }
      }
    }

    this.getWidgetData();
  }
}
