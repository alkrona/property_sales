
# Property Sals Project Setup Guide

## Initial Setup

### 1. Fork and Clone Repository
```bash
# Fork via GitHub UI (click Fork button)
# Then clone your forked repository
git clone https://github.com/alkrona/property_sales
cd repository-name
```
## Virtual enviorment setup
```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate
```
## Install dependencies
```bash
# Install dependencies
pip install -r requirements.txt

```
## Start Front End Website
```bash
python home.py
# And go to local host : http://127.0.0.1:8050/
```

## Contact 
| Kiran Jais Chemmanatte | [kiranjais6@gmail.com](mailto:kiranjais6@gmail.com) |
# Project References

## Video Tutorials
- [Dask Tutorial](https://www.youtube.com/watch?v=YU7bCEcsBK8)

## Data Sources
- [Heat Maps Australia](https://heatmaps.com.au)
- [NSW Property Sales Information](https://valuation.property.nsw.gov.au/embed/propertySalesInformation)

## Geographical Data
- [NSW Suburb GeoJSON Data](https://github.com/tonywr71/GeoJson-Data/blob/master/suburb-2-nsw.geojson)
- [All Australia shapefiles](https://web2.spatialvision.com.au/wp-content/uploads/2019/01/geopandas-blog.zip)
## Australian Postal Data
### Primary Source
- [Australia Post Code Dataset (SQL)](https://gist.githubusercontent.com/randomecho/5020859/raw/f0c1385aefa8322c9c4eb7c43ac4c7dda41227eb/australian-postcodes.sql)

### Alternative Source
- [Matthew Proctor's Australian Postcodes](https://www.matthewproctor.com/australian_postcodes)

---