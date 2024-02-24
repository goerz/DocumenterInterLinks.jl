using DocumenterInterLinks
using DocInventories
using Documenter
using Test

include("run_makedocs.jl")


@testset "Integration Test" begin

    # We build the documentation of DocumenterInterLinks itself as a test

    links = InterLinks(
        "Documenter" => (
            "https://documenter.juliadocs.org/stable/",
            joinpath(@__DIR__, "..", "docs", "src", "inventories", "Documenter.toml")
        ),
        "Julia" => (
            "https://docs.julialang.org/en/v1/",
            joinpath(@__DIR__, "..", "docs", "src", "inventories", "Julia.toml")
        ),
        "DocInventories" => (
            "https://github.com/JuliaDocs/DocInventories.jl/",
            joinpath(@__DIR__, "..", "docs", "src", "inventories", "DocInventories.toml")
        ),
        "sphinx" => "https://www.sphinx-doc.org/en/master/",
        "sphobjinv" => "https://sphobjinv.readthedocs.io/en/stable/",
        "matplotlib" => "https://matplotlib.org/3.7.3/",
    )

    Base.eval(Main, quote
        using DocumenterInterLinks
        PAGES = []  # We don't care about the order of pages for the test
    end)

    run_makedocs(
        joinpath(@__DIR__, "..", "docs");
        sitename="DocumenterInterLinks.jl",
        plugins=[links],
        format=Documenter.HTML(;
            prettyurls = true,
            canonical  = "https://juliadocs.github.io/DocumenterInterLinks.jl",
            footer     = "Generated by Test",
            edit_link  = "",
            repolink   = ""
        ),
        check_success=true
    ) do dir, result, success, backtrace, output

        inventory_file = joinpath(dir, "build", "objects.inv")
        @test isfile(inventory_file)
        if isfile(inventory_file)
            inventory = Inventory(inventory_file; root_url="")
            specs = [
                ":jl:type:`DocumenterInterLinks.InterLinks`",
                ":jl:method:`DocumenterInterLinks.find_in_interlinks-Tuple{InterLinks, AbstractString}`",
                ":std:doc:`api/internals`",
                # :doc: names should always use unix path separators
            ]
            for spec in specs
                @test !isnothing(inventory[spec])
            end
            for item in inventory
                # URIs should never use Windows path separators
                @test !contains(item.uri, "\\")
            end
        end

    end

end
