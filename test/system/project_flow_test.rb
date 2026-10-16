require "application_system_test_case"

class ProjectFlowTest < ApplicationSystemTestCase
  test "set up a project, slip on a day, note why and see it in the results" do
    travel_to_day Date.new(2026, 10, 12)

    visit new_project_path
    fill_in "Nome", with: "Comer melhor"
    fill_in "Início", with: Date.new(2026, 10, 1)
    click_on "Criar projeto"
    assert_text "dia 12 de 75"

    click_on "Novo grupo"
    fill_in "Nome", with: "Alimentação"
    click_on "Criar grupo"

    click_on "Novo desafio"
    fill_in "Nome", with: "Sem refri"
    click_on "Criar desafio"
    assert_text "12 dias perfeitos"

    click_on "Dia 3: marcar vacilo"
    assert_text "11 dias perfeitos"

    click_on "Dia 3: vacilo, editar"
    fill_in "Nota", with: "aniversário"
    click_on "Salvar"

    click_on "Resultado"
    assert_text "Dia 3 · Sem refri · aniversário"
  end
end
