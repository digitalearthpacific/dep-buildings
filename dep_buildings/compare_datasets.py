import geopandas as gpd
import pandas as pd


def main():
    osm = gpd.read_file("data/dep_buildings_0-1-1.gpkg")
    eez = gpd.read_file("data/country_boundary_eez.gpkg")
    osm_counts = osm.ISO_Ter1.value_counts().rename("OpenStreetMap")

    overture = gpd.read_file("data/dep_overture_buildings_2025-11-19.0.gpkg")
    overture_counts = (
        # Mitigate duplicate features, I don't know why they're there yet
        overture.groupby("id")
        .first()
        .set_crs(overture.crs)
        .sjoin(eez.to_crs(overture.crs))
        .ISO_Ter1.value_counts()
        .rename("Overture")
    )

    spc_countries_and_layers = dict(
        COK="data/pcrafi_ck_residential_building_class_2024.zip",
        SLB="data/pcrafi_sb_residential_building_class_2024.zip",
        TON="data/pcrafi_to_residential_building_class_2024.zip",
        VUT="data/pcrafi_vu_residential_building_class_2024.zip",
        WSM="data/pcrafi_vu_residential_building_class_2024.zip",
        TUV="data/tv_building_footprints.zip",
    )

    spc_country_and_count = []
    for country, zip_file in spc_countries_and_layers.items():
        spc_country_and_count.append(
            {"ISO_Ter1": country, "count": len(gpd.read_file(zip_file))}
        )
    spc_counts = (
        pd.DataFrame(spc_country_and_count)
        .set_index("ISO_Ter1")["count"]
        .rename("SPC - PCRAFI")
    )

    code_to_country_name = {
        "PNG": "Papua New Guinea",
        "FJI": "Fiji",
        "VUT": "Vanuatu",
        "PYF": "French Polynesia",
        "SLB": "Solomon Islands",
        "NCL": "New Caledonia",
        "WSM": "Samoa",
        "TON": "Tonga",
        "KIR": "Kiribati",
        "GUM": "Guam",
        "FSM": "Federated States of Micronesia",
        "ASM": "American Samoa",
        "MNP": "Northern Mariana Islands",
        "COK": "Cook Islands",
        "MHL": "Republic of Marshall Islands",
        "WLF": "Wallis and Futuna",
        "PLW": "Palau",
        "TUV": "Tuvalu",
        "NRU": "Nauru",
        "NIU": "Niue",
        "TKL": "Tokelau",
        "PCN": "Pitcairn Islands",
    }

    output = pd.concat([osm_counts, overture_counts, spc_counts], axis=1).reset_index()
    output["Name"] = output.ISO_Ter1.map(code_to_country_name)
    output.sort_values(by="Name").to_csv("data/comparison.csv", index=False)


if __name__ == "__main__":
    main()
