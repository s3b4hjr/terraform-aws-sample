package main

import (
	"context"
	"fmt"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/timestreamquery"
	"github.com/aws/aws-sdk-go-v2/service/timestreamwrite"
	timestreamwritetypes "github.com/aws/aws-sdk-go-v2/service/timestreamwrite/types"
)

func main() {
	// Configuração do AWS SDK com credenciais e região
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion("us-east-1"), // Ajuste para sua região
		// Se estiver fora da AWS, descomente e forneça as credenciais do IAM user
		// config.WithCredentialsProvider(credentials.NewStaticCredentialsProvider(
		//     "SUA_ACCESS_KEY_ID",      // Substitua pelo output do Terraform
		//     "SUA_SECRET_ACCESS_KEY",   // Substitua pelo output do Terraform
		//     "",
		// )),
	)
	if err != nil {
		fmt.Printf("Erro ao carregar configuração: %v\n", err)
		return
	}

	// Criar clientes para Timestream Write e Query
	writeClient := timestreamwrite.NewFromConfig(cfg)
	queryClient := timestreamquery.NewFromConfig(cfg)

	// Escrever dados no Timestream
	err = writeData(writeClient)
	if err != nil {
		fmt.Printf("Erro ao escrever dados: %v\n", err)
		return
	}
	fmt.Println("Dados escritos com sucesso!")

	// Consultar dados no Timestream
	err = queryData(queryClient)
	if err != nil {
		fmt.Printf("Erro ao consultar dados: %v\n", err)
		return
	}
}

// Função para escrever dados no Timestream
func writeData(client *timestreamwrite.Client) error {
	currentTime := time.Now().UnixMilli() // Timestamp em milissegundos

	records := []timestreamwritetypes.Record{
		{
			Dimensions: []timestreamwritetypes.Dimension{
				{Name: aws.String("region"), Value: aws.String("us-east-1")},
				{Name: aws.String("host"), Value: aws.String("server-go")},
			},
			MeasureName:      aws.String("cpu_usage"),
			MeasureValue:     aws.String("65.8"),
			MeasureValueType: timestreamwritetypes.MeasureValueTypeDouble,
			Time:             aws.String(fmt.Sprintf("%d", currentTime)),
			TimeUnit:         timestreamwritetypes.TimeUnitMilliseconds,
		},
	}

	_, err := client.WriteRecords(context.TODO(), &timestreamwrite.WriteRecordsInput{
		DatabaseName: aws.String("cadastro"),
		TableName:    aws.String("teste"),
		Records:      records,
	})
	return err
}

// Função para consultar dados no Timestream
func queryData(client *timestreamquery.Client) error {
	query := `
		SELECT region, host, measure_name, time, measure_value::double
		FROM "cadastro"."teste"
		WHERE measure_name = 'cpu_usage' AND time > ago(1h)
	`

	input := &timestreamquery.QueryInput{
		QueryString: aws.String(query),
	}

	result, err := client.Query(context.TODO(), input)
	if err != nil {
		return err
	}

	// Processar os resultados
	for _, row := range result.Rows {
		for _, data := range row.Data {
			if data.ScalarValue != nil {
				fmt.Printf("%v ", *data.ScalarValue)
			}
		}
		fmt.Println()
	}

	return nil
}
