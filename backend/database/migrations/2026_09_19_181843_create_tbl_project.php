<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_project', function (Blueprint $table) {
            $table->bigIncrements('v_projectId');

            $table->string('v_projectNumber', 60)
                ->nullable()
                ->unique();

            $table->unsignedBigInteger('v_serviceRequestId');

            $table->unsignedBigInteger('v_quotationId')
                ->nullable();

            $table->string('v_projectName', 150)
                ->nullable();

            $table->text('v_projectDescription')
                ->nullable();

            $table->string('v_projectLocation', 255)
                ->nullable();

            $table->dateTime('v_startDate')
                ->nullable();

            $table->dateTime('v_targetCompletionDate')
                ->nullable();

            $table->dateTime('v_actualCompletionDate')
                ->nullable();

            $table->string('v_projectStatus', 50)
                ->nullable();

            $table->decimal('v_progressPercentage', 5, 2)
                ->nullable();

            $table->decimal('v_contractAmount', 14, 2)
                ->nullable();

            $table->text('v_notes')
                ->nullable();

            $table->dateTime('v_createdAt')
                ->useCurrent();

            $table->dateTime('v_updatedAt')
                ->useCurrent();

            $table->foreign(
                'v_serviceRequestId',
                'fk_project_serviceRequest'
            )
                ->references('v_serviceRequestId')
                ->on('tbl_serviceRequest')
                ->onUpdate('cascade')
                ->onDelete('restrict');

            $table->foreign(
                'v_quotationId',
                'fk_project_quotation'
            )
                ->references('v_quotationId')
                ->on('tbl_quotation')
                ->onUpdate('cascade')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_project');
    }
};