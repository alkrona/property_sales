from dash import Dash,dcc,html,Input,Output
import geopandas as gpd
import plotly.express as px
import pandas as pd

# 
dropdown_values = {
    "region":['NSW'],
    'years':[2021,2022,2023],
}

app = Dash(__name__)
app.layout=html.Div([
    dcc.Dropdown(
        id="region-dropdown",
        options=[{"label":region,"value":region} for region in dropdown_values['region']],
        value="NSW",
    ),
    dcc.Dropdown(
        id="year-dropdown",
        options=[{"label":year,"value":year}for year in dropdown_values["years"]],
        value=2023,
    ),
    html.Div([
        dcc.Graph(id="plot1"),
        dcc.Graph(id="plot2"),
    ])
])
# defining callbacks
@app.callback(
    [Output("plot1","figure"),
     Output('plot2',"figure")],
     [Input('region-dropdown','value'),
      Input('year-dropdown','value')]
)

def update_figure(selected_region,selected_year):
    csv_file_path = "data/property_data/2023_property_data.csv"
    data = pd.read_csv(csv_file_path)
    region_geojson_path = "data/geojson_data/suburb-2-nsw.geojson"
    region_geojson = gpd.read_file(region_geojson_path)
    # creating the figure
    #NOT IMPLEMENTED YET

if __name__ =='__main__':
    app.run_server(debug=True)
